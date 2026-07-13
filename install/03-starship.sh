#!/usr/bin/env bash
# starship prompt config (binary installed via Brewfile).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "starship"
has starship && ok "starship $(starship --version | head -1 | awk '{print $2}')" \
             || warn "starship binary missing (should come from Brewfile)"
link "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
