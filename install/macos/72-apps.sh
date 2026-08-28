#!/usr/bin/env bash
# GUI apps installed as casks: the manual steps each still needs.
#
# The apps themselves come from the packages module. What can't be scripted is
# the permissions each one asks for on first launch — that's what this prints.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "GUI apps"

# espanso's config is cross-platform and tracked; the binary is the cask.
if has espanso; then
  if ! espanso status >/dev/null 2>&1; then
    info "registering espanso service..."
    run_sh 'espanso service register >/dev/null 2>&1 || true'
    run_sh 'espanso start >/dev/null 2>&1 || true'
  fi
  ok "espanso running (config linked by 40-links)"
else
  warn "espanso not installed — expected from the packages module"
fi

# Checked through brew rather than /Applications: several of these casks put
# their bundle somewhere other than the name suggests (iterm2 -> iTerm.app), so
# a path check reports false negatives.
app_note() {
  if brew list --cask "$1" >/dev/null 2>&1; then ok "$1 — $2"
  else info "$1 not installed — $2"; fi
}
app_note "nikitabobko/tap/aerospace" "grant Accessibility permission on first launch"
app_note "karabiner-elements"        "grant Input Monitoring permission on first launch"
app_note "docker-desktop"            "start once to create the docker socket"
app_note "iterm2"                    "set the font to a Nerd Font for prompt glyphs"

info "System Settings -> Privacy & Security -> Accessibility / Input Monitoring"
exit 0
