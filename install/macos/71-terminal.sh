#!/usr/bin/env bash
# iTerm2 preferences — imported into the macOS defaults DB, not symlinked.
#
# iTerm2 stores prefs in a plist it rewrites on quit, so a symlink would fight
# it. Re-export after changing settings with `dot iterm-export`, then `dot push`.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Terminal (iTerm2)"

PLIST="$CONFIG_DIR/iterm2/com.googlecode.iterm2.plist"
if [ ! -f "$PLIST" ]; then warn "no iTerm2 plist tracked"; exit 0; fi

if ask "Import iTerm2 preferences? (quit iTerm2 first)"; then
  run defaults import com.googlecode.iterm2 "$PLIST"
  ok "iTerm2 prefs imported (restart iTerm2 to apply)"
fi

info "Nerd Fonts install as casks via the packages module"
info "to re-export your current prefs into the repo:  dot iterm-export"
