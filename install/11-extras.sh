#!/usr/bin/env bash
# GUI / system extras (casks installed via the Brewfile): espanso, aerospace,
# karabiner-elements, android tools, docker desktop, raycast.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Extras (espanso, aerospace, karabiner, ...)"

# espanso — config is tracked; register the background service.
if [ -d "$CONFIG_DIR/espanso" ]; then
  link "$CONFIG_DIR/espanso" "$HOME/.config/espanso"
  if has espanso && ! espanso status >/dev/null 2>&1; then
    info "registering espanso service..."
    espanso service register >/dev/null 2>&1 || true
    espanso start >/dev/null 2>&1 || true
  fi
fi

# aerospace / karabiner: apps come from the Brewfile. No configs are tracked
# yet (you were on defaults). Drop configs under config/<tool>/ and add a
# link line here when you want them versioned.
info "aerospace, karabiner-elements, android tools, docker-desktop installed via Brewfile"
info "grant macOS Accessibility/Input-Monitoring permissions on first launch"
