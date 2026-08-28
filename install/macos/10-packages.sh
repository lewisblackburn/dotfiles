#!/usr/bin/env bash
# All macOS packages: formulae, casks and VS Code extensions from the registry.
#
# The package list is packages/tools.csv, shared with Linux — this module just
# renders the macOS column into a Brewfile and runs `brew bundle` on it.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"

log "Packages (Homebrew)"

if ! has_brew; then err "Homebrew missing — run: ./install.sh --only 01-homebrew"; exit 1; fi
brew_shellenv
brew_apply_registry
