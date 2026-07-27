#!/usr/bin/env bash
# Global git config.
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "git"
link "$CONFIG_DIR/git/.gitconfig" "$HOME/.gitconfig"
