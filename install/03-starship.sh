#!/usr/bin/env bash
# starship prompt config (binary installed by module 01).
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "starship"
has starship && ok "starship $(starship --version | head -1 | awk '{print $2}')" \
             || warn "starship binary missing (should come from module 01)"
link "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
