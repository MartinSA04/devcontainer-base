#!/usr/bin/env bash
set -euo pipefail

echo "Installing base dependencies..."
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl gnupg

echo "Installing mise..."
curl -fsSL https://mise.jdx.dev/install.sh | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> /etc/bash.bashrc

if [ "${INSTALLZSH}" = "true" ]; then
  apt-get install -y --no-install-recommends zsh
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> /etc/zsh/zshrc
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

echo "mise-and-tools install complete."