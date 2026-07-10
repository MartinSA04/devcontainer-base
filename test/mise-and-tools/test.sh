#!/bin/bash
set -e
source dev-container-features-test-lib

check "mise is installed" bash -c "command -v mise"
check "gh is installed" bash -c "command -v gh"
# Claude Code lives in the remote user's ~/.local/bin; a login shell puts it on
# PATH via /etc/profile.d, matching how a real terminal in the container works.
check "claude is installed" bash -lc "command -v claude"

reportResults
