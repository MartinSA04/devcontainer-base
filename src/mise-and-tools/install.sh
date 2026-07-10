#!/usr/bin/env bash
set -euo pipefail

echo "Installing base dependencies..."
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl gnupg

echo "Installing mise..."
# Install system-wide so the tool is on PATH for the container's remote user,
# not just the root user that runs the feature build.
curl -fsSL https://mise.jdx.dev/install.sh | MISE_INSTALL_PATH=/usr/local/bin/mise sh
echo 'eval "$(mise activate bash)"' >> /etc/bash.bashrc

if [ "${INSTALLZSH}" = "true" ]; then
  apt-get install -y --no-install-recommends zsh
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  echo 'eval "$(mise activate zsh)"' >> /etc/zsh/zshrc
  echo 'eval "$(starship init zsh)"' >> /etc/zsh/zshrc
fi

if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt-get update -y
  apt-get install -y gh
fi

if [ "${INSTALLCLAUDECODE}" = "true" ]; then
  echo "Installing Claude Code..."
  # The official installer is home-directory based: it drops the launcher in
  # ~/.local/bin and keeps login/history/memory under ~/.claude. Install it AS
  # the container's remote user (with that user's HOME) so it lands in their
  # home rather than root's — otherwise a non-root user (e.g. vscode) can't see it.
  CLAUDE_USER="${_REMOTE_USER:-root}"
  CLAUDE_HOME="${_REMOTE_USER_HOME:-$(getent passwd "${CLAUDE_USER}" | cut -d: -f6)}"
  CLAUDE_HOME="${CLAUDE_HOME:-/root}"

  # Pre-create user-owned state dirs. ~/.claude holds credentials/history/memory
  # (and, with CLAUDE_CONFIG_DIR set, the login session) that the template
  # persists on a named volume.
  install -d -o "${CLAUDE_USER}" -g "${CLAUDE_USER}" \
    "${CLAUDE_HOME}/.claude" \
    "${CLAUDE_HOME}/.ai-auth" \
    "${CLAUDE_HOME}/.ai-auth/claude"

  if [ "${CLAUDE_USER}" = "root" ]; then
    HOME="${CLAUDE_HOME}" bash -c "curl -fsSL https://claude.ai/install.sh | bash -s -- '${CLAUDECODEVERSION}'"
  else
    su - "${CLAUDE_USER}" -c "curl -fsSL https://claude.ai/install.sh | bash -s -- '${CLAUDECODEVERSION}'"
  fi

  # Make ~/.local/bin (where the launcher lives) discoverable in login and
  # interactive shells for whichever user opens a terminal.
  echo 'export PATH="$HOME/.local/bin:$PATH"' > /etc/profile.d/local-bin.sh
  chmod +x /etc/profile.d/local-bin.sh
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/bash.bashrc

  echo "Claude Code installed to ${CLAUDE_HOME}/.local/bin/claude"
fi

echo "mise-and-tools install complete."
