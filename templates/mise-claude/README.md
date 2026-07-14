
# mise + persistent Claude Code (mise-claude)

A dev container preloaded with mise, git, gh, and Claude Code, where Claude's login session, history, and memory persist across container rebuilds via a named volume.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Base image variant (Microsoft dev container base images; all use the 'vscode' user) | string | ubuntu |
| installZsh | Install zsh and the starship prompt | boolean | true |
| claudeCodeVersion | Claude Code version to install (stable, latest, or a pinned x.y.z) | string | stable |

## GitHub SSH

`git` over SSH to `github.com` authenticates with a single key: `~/.ssh/id_git`.

The container bind-mounts that one host key read-only (never your other keys),
and `.devcontainer/post-create.sh` writes an `~/.ssh/config` that pins
`github.com` to it with `IdentitiesOnly yes` — so even when VS Code forwards a
host SSH agent holding other identities (e.g. work keys), only `id_git` is ever
offered to GitHub.

**Requires `~/.ssh/id_git` (the private key) to exist on the host.** If it does
not, the container fails to start on the missing bind-mount source. Using a
different filename or don't need GitHub SSH? Drop the `id_git` line from
`mounts` in `.devcontainer/devcontainer.json` and the SSH block from
`.devcontainer/post-create.sh`.

## GitHub CLI (`gh`) auth

The `gh` CLI reuses your host login. The container bind-mounts `~/.config/gh`
(which holds `hosts.yml` with the auth token) read-write, so `gh` commands work
immediately with no `gh auth login` step inside the container, and any token
refresh flows back to the host.

**Requires that you're already logged in on the host (`gh auth login`), so
`~/.config/gh` exists.** If it does not, the container fails to start on the
missing bind-mount source. Don't need `gh`? Drop the `~/.config/gh` line from
`mounts` in `.devcontainer/devcontainer.json`.

This is `gh` CLI auth only; `git` over SSH still authenticates with `id_git`
(see above).


---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/MartinSA04/devcontainer-base/blob/main/templates/mise-claude/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
