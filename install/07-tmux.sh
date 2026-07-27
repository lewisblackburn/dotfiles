#!/usr/bin/env bash
# tmux (binary installed by module 01).
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "tmux"
has tmux && ok "tmux $(tmux -V | awk '{print $2}')" \
         || warn "tmux missing (should come from module 01)"

# Link a config only if one exists in the repo (none tracked yet).
if [ -f "$CONFIG_DIR/tmux/tmux.conf" ]; then
  link "$CONFIG_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
else
  info "no tmux.conf tracked — using defaults"
fi
