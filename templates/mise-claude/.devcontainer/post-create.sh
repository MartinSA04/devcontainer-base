#!/usr/bin/env bash
set -euo pipefail

# A freshly created volume is root-owned — hand the dep dirs to the remote user,
# then provision the mise toolchain. `mise` itself is on PATH here, but the tools
# it manages are NOT auto-activated in this non-interactive shell, so your own
# install step must go through `mise exec --` (e.g. `mise exec -- pnpm install`).
sudo chown -R "$(whoami)" node_modules .venv 2>/dev/null || true
mise trust && mise install

# GitHub auth over SSH: use only ~/.ssh/id_git (bind-mounted read-only from the
# host). `IdentitiesOnly yes` makes ssh ignore every other key the forwarded
# agent offers, so the correct key is always used for github.com.
sudo install -d -m 700 -o "$(whoami)" -g "$(whoami)" "$HOME/.ssh"
cat > "$HOME/.ssh/config" <<'EOF'
Host github.com
  User git
  IdentityFile ~/.ssh/id_git
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
EOF
chmod 600 "$HOME/.ssh/config"
