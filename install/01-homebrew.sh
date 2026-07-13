#!/usr/bin/env bash
# Homebrew + every formula/cask/font/vscode-extension from the Brewfile.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Homebrew"

if ! has brew; then
  info "installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # make brew available in this shell (Apple Silicon path)
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
else
  ok "Homebrew present"
fi

log "brew bundle (installs/updates everything in Brewfile — safe to re-run)"
brew bundle --file="$DOTFILES/Brewfile"
ok "Brewfile applied"
