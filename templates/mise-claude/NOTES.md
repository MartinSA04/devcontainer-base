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
