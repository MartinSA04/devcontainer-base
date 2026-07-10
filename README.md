# devcontainer-base

A personal dev container baseline, published to GitHub Container Registry:

- A **Feature** — [`mise-and-tools`](src/mise-and-tools) — installs [mise](https://mise.jdx.dev/) (polyglot tool version manager), `git`, `gh`, [Claude Code](https://code.claude.com/docs), and optionally `zsh` + [starship](https://starship.rs/).
- A **Template** — [`mise-claude`](templates/mise-claude) — scaffolds a ready-to-go project that uses the feature **and** persists Claude Code's login session, history, and memory across container rebuilds.

## Quickest start: apply the Template to a new project

```bash
devcontainer templates apply \
  -t ghcr.io/martinsa04/devcontainer-base/mise-claude \
  -a '{ "imageVariant": "ubuntu", "installZsh": true, "claudeCodeVersion": "stable" }'
```

(Or, in VS Code: **Dev Containers: New Dev Container…** → search for this template.)

This drops a `.devcontainer/devcontainer.json` into your project with the feature, a persistence volume, and the right environment already wired up. Open the folder in a container and you're set.

## Or add just the Feature to an existing project

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/martinsa04/devcontainer-base/mise-and-tools:1": {
      "installZsh": true,
      "installClaudeCode": true,
      "claudeCodeVersion": "stable"
    }
  }
}
```

### Feature options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `installZsh` | boolean | `true` | Install `zsh` and the starship prompt. |
| `installClaudeCode` | boolean | `true` | Install the Claude Code CLI for the remote user. |
| `claudeCodeVersion` | string | `stable` | Claude Code version (`stable`, `latest`, or a pinned `x.y.z`). |

mise is installed system-wide (`/usr/local/bin/mise`) and activated in interactive shells. Each project declares whatever tools it needs via its own `.mise.toml` / `.tool-versions` — the feature just provides mise itself.

Claude Code is installed **per user** via the official installer, into the remote user's `~/.local/bin` and `~/.claude`.

## Claude persistence is automatic (feature-owned)

A rebuild recreates the container filesystem, which would normally wipe your Claude login, history, and memory. The **feature handles this for you** — just adding `mise-and-tools` persists Claude, with no `mounts`/`containerEnv` to copy into your project. The feature contributes three things to the container:

1. **`CLAUDE_CONFIG_DIR=/home/vscode/.claude`** — pulls `~/.claude.json` (the **login session**) into `~/.claude`, so one directory holds login + credentials + history + memory.
2. **A named volume** `claude-${devcontainerId}` mounted at `/home/vscode/.claude` — stable across rebuilds, isolated per project.
3. **A `postCreateCommand`** that chowns that volume to the remote user so Claude can write to it.

Rebuild as often as you like — you stay logged in and keep your history and memory.

> **Caveats of feature-owned persistence.** Feature mounts can't reference `$HOME`, so the paths are hardcoded to the **`vscode` user** (`/home/vscode/.claude`) — the standard user on the `mcr.microsoft.com/devcontainers/base:*` images. On a root-based image it still works but stores state under `/home/vscode`. And every project using the feature gets its own `claude-*` volume automatically — the intended behavior for this personal baseline.

## Keeping `node_modules` / `.venv` out of the bind mount

Your project folder is bind-mounted from the host. If you run the same tooling **both** on the host and in the container, an install inside the container writes arch-/libc-specific binaries onto the host's `node_modules` / `.venv` (and vice versa), corrupting each other. Mount a named volume **over** those subpaths so the container gets its own copy the host never sees — this is baked into the `mise-claude` template:

```jsonc
"mounts": [
  "source=node-modules-${devcontainerId},target=${containerWorkspaceFolder}/node_modules,type=volume",
  "source=venv-${devcontainerId},target=${containerWorkspaceFolder}/.venv,type=volume"
]
```

No more host/container conflicts, and installs are notably faster ([why](https://code.visualstudio.com/remote/advancedcontainers/improve-performance)). Gotchas:

- **Ownership:** a fresh volume is root-owned; the template's `postCreateCommand` chowns `node_modules .venv` to the remote user before installing, or `pnpm`/`uv` fail with permission errors ([ref](https://github.com/microsoft/vscode-remote-release/issues/6669)).
- **Drop what you don't use:** an unused `.venv` volume just appears as an empty dir — remove that mount line for a node-only (or python-only) project.
- **uv cache (optional):** to also cache uv downloads across rebuilds, give `~/.cache/uv` its own volume, or point `UV_CACHE_DIR` at a persisted path.

## The mise bootstrap + a `mise exec` gotcha

The template's `postCreateCommand` provisions the toolchain automatically:

```
sudo chown -R $(whoami) node_modules .venv 2>/dev/null; mise trust && mise install
```

`mise` itself is on `PATH` in that non-interactive shell (installed to `/usr/local/bin`), but the **tools it manages are not auto-activated** there — `mise activate` only runs in interactive shells. So a project's own install step must go through `mise exec` (aka `mise x`):

```
... && mise exec -- pnpm install
```

Append your install command to the template's `postCreateCommand` that way — exactly how a downstream project (e.g. an Astro app running `pnpm install`) extends it.

## Repo structure

```
├── src                          # Features (base-path-to-features)
│   └── mise-and-tools/
│       ├── devcontainer-feature.json
│       └── install.sh
├── templates                    # Templates (base-path-to-templates)
│   └── mise-claude/
│       ├── devcontainer-template.json
│       └── .devcontainer/devcontainer.json
├── test
│   └── mise-and-tools/test.sh
└── .github/workflows            # test, validate, release (features + templates)
```

## Development

Run the feature test suite locally (requires Docker + the dev container CLI):

```bash
devcontainer features test --skip-scenarios -f mise-and-tools -i mcr.microsoft.com/devcontainers/base:ubuntu .
```

The [release workflow](.github/workflows/release.yaml) publishes the Feature (from `./src`) and the Template (from `./templates`) to `ghcr.io/martinsa04/devcontainer-base/*`. GHCR packages default to private — mark them public to use them without auth.
