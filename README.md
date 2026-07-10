# devcontainer-base

A personal dev container baseline, published to GitHub Container Registry:

- A **Feature** — [`mise-and-tools`](src/mise-and-tools) — installs [mise](https://mise.jdx.dev/) (polyglot tool version manager), `git`, `gh`, [Claude Code](https://code.claude.com/docs), and optionally `zsh` + [starship](https://starship.rs/).
- A **Template** — [`mise-claude`](src/mise-claude) — scaffolds a ready-to-go project that uses the feature **and** persists Claude Code's login session, history, and memory across container rebuilds.

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

## How Claude persistence works

A container rebuild recreates the container filesystem, which would normally wipe your Claude login, chat history, and project memory. The `mise-claude` template prevents this with two pieces:

1. **`CLAUDE_CONFIG_DIR=/home/vscode/.claude`** — this pulls `~/.claude.json` (which holds the **login session**) *into* the `~/.claude` directory, alongside credentials, history, and memory. Everything Claude needs to persist now lives under one directory.
2. **A named Docker volume mounted at `~/.claude`:**
   ```jsonc
   "mounts": [
     "source=claude-${devcontainerId},target=/home/vscode/.claude,type=volume"
   ]
   ```
   The volume is keyed by `${devcontainerId}`, so it is stable across rebuilds but isolated per project. A `postCreateCommand` chowns the freshly created (root-owned) volume to the remote user so Claude can write to it.

The result: rebuild your container as often as you like — you stay logged in and keep your history and memory.

> If you add the feature to a project *without* the template, replicate those three lines (`containerEnv`, `mounts`, `postCreateCommand`) in your own `devcontainer.json` to get the same persistence. See [`src/mise-claude/.devcontainer/devcontainer.json`](src/mise-claude/.devcontainer/devcontainer.json) for the reference.

## Repo structure

```
├── src
│   ├── mise-and-tools/          # the Feature
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   └── mise-claude/             # the Template
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

Both the Feature and the Template are published from `./src` by the [release workflow](.github/workflows/release.yaml) to `ghcr.io/martinsa04/devcontainer-base/*`. GHCR packages default to private — mark them public to use them without auth.
