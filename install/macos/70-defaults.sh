#!/usr/bin/env bash
# macOS system preferences — the `defaults write` settings worth having everywhere.
#
# Every setting here is one you'd otherwise click through System Settings on a
# fresh Mac. All are reversible; the value each replaces is noted where it isn't
# obvious. Skipped entirely unless you opt in, since these are personal.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "macOS defaults"

if ! ask "Apply macOS system preferences (keyboard, Finder, Dock)?"; then
  info "skipped"; exit 0
fi

set_default() {
  local desc="$1"; shift
  run defaults write "$@" && ok "$desc"
}

# ---- keyboard: the one that matters most for a vim setup ------------------
# KeyRepeat 1 / InitialKeyRepeat 12 is faster than the System Settings minimum.
set_default "fast key repeat"            NSGlobalDomain KeyRepeat -int 1
set_default "short repeat delay"         NSGlobalDomain InitialKeyRepeat -int 12
# Press-and-hold shows the accent menu instead of repeating — useless in vim.
set_default "disable press-and-hold"     NSGlobalDomain ApplePressAndHoldEnabled -bool false
set_default "full keyboard access"       NSGlobalDomain AppleKeyboardUIMode -int 3
set_default "no autocorrect"             NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
set_default "no smart quotes"            NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
set_default "no smart dashes"            NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ---- finder ---------------------------------------------------------------
set_default "show file extensions"       NSGlobalDomain AppleShowAllExtensions -bool true
set_default "show hidden files"          com.apple.finder AppleShowAllFiles -bool true
set_default "show path bar"              com.apple.finder ShowPathbar -bool true
set_default "show status bar"            com.apple.finder ShowStatusBar -bool true
set_default "list view by default"       com.apple.finder FXPreferredViewStyle -string "Nlsv"
set_default "search current folder"      com.apple.finder FXDefaultSearchScope -string "SCcf"
set_default "no .DS_Store on network"    com.apple.desktopservices DSDontWriteNetworkStores -bool true

# ---- dock -----------------------------------------------------------------
set_default "autohide dock"              com.apple.dock autohide -bool true
set_default "instant dock autohide"      com.apple.dock autohide-time-modifier -float 0.15
set_default "no dock hide delay"         com.apple.dock autohide-delay -float 0
set_default "small dock icons"           com.apple.dock tilesize -int 40
set_default "no recent apps in dock"     com.apple.dock show-recents -bool false
# Mission Control reordering fights aerospace's workspace assignment.
set_default "static spaces order"        com.apple.dock mru-spaces -bool false

# ---- screenshots ----------------------------------------------------------
run mkdir -p "$HOME/Screenshots"
set_default "screenshots to ~/Screenshots" com.apple.screencapture location -string "$HOME/Screenshots"
set_default "png screenshots"            com.apple.screencapture type -string "png"
set_default "no screenshot shadows"      com.apple.screencapture disable-shadow -bool true

if ask "Restart Finder and Dock to apply now?"; then
  run killall Finder || true
  run killall Dock   || true
  ok "Finder and Dock restarted"
else
  info "log out and back in to apply the rest"
fi
