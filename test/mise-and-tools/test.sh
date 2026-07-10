#!/bin/bash
set -e
source dev-container-features-test-lib

check "mise is installed" bash -c "command -v mise"
check "gh is installed" bash -c "command -v gh"

reportResults