#!/usr/bin/env bash
# starship prompt config (binary installed by module 01).
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "starship"

# The binary normally comes from module 01 (Brewfile cask on macOS, official
# installer on Linux). If this module is run standalone, install it here too so
# the config we're about to link isn't dead weight.
if ! has starship && is_linux; then
  info "starship missing — installing to ~/.local/bin..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "$HOME/.local/bin" >/dev/null 2>&1 || true
  export PATH="$HOME/.local/bin:$PATH"
fi

has starship && ok "starship $(starship --version | head -1 | awk '{print $2}')" \
             || warn "starship binary missing (run module 01, or see https://starship.rs)"
link "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
