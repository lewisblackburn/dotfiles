#!/usr/bin/env bash
# iTerm2 preferences (installed as a cask via the Brewfile).
# iTerm2 stores prefs in a macOS plist, so we import rather than symlink.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Terminal (iTerm2)"

PLIST="$CONFIG_DIR/iterm2/com.googlecode.iterm2.plist"
if [ -f "$PLIST" ]; then
  if ask "Import iTerm2 preferences? (quit iTerm2 first)"; then
    defaults import com.googlecode.iterm2 "$PLIST"
    ok "iTerm2 prefs imported (restart iTerm2 to apply)"
  fi
else
  warn "no iTerm2 plist tracked"
fi

info "Fonts (Fira Code / Hack Nerd Font) install via the Brewfile casks."
info "To re-export current iTerm2 prefs into the repo:  dot iterm-export"
