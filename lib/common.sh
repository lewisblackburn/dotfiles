#!/usr/bin/env bash
# Shared helpers for the dotfiles install scripts.
# Sourced by install.sh and every install/*.sh module.

# Repo root (this file lives in <repo>/lib/common.sh)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES
export CONFIG_DIR="$DOTFILES/config"

# ---- pretty logging -------------------------------------------------------
if [ -t 1 ]; then
  _c_reset=$'\033[0m'; _c_blue=$'\033[34m'; _c_green=$'\033[32m'
  _c_yellow=$'\033[33m'; _c_red=$'\033[31m'; _c_bold=$'\033[1m'
else
  _c_reset=""; _c_blue=""; _c_green=""; _c_yellow=""; _c_red=""; _c_bold=""
fi

log()  { printf '%s\n' "${_c_blue}==>${_c_reset} ${_c_bold}$*${_c_reset}"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '%s\n' "    ${_c_green}✓${_c_reset} $*"; }
warn() { printf '%s\n' "    ${_c_yellow}!${_c_reset} $*"; }
err()  { printf '%s\n' "    ${_c_red}✗${_c_reset} $*" >&2; }

# ---- small utilities ------------------------------------------------------
has() { command -v "$1" >/dev/null 2>&1; }

is_macos() { [ "$(uname -s)" = "Darwin" ]; }

# ask "Question?" [Y/n default yes]  -> returns 0 for yes.
# Honors DOTFILES_YES=1 (assume yes, for non-interactive runs).
ask() {
  local prompt="$1" default="${2:-Y}" reply
  if [ "${DOTFILES_YES:-0}" = "1" ]; then return 0; fi
  if [ "$default" = "Y" ]; then prompt="$prompt [Y/n] "; else prompt="$prompt [y/N] "; fi
  read -r -p "$(printf '%s' "${_c_yellow}?${_c_reset} $prompt")" reply || return 1
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

# link <source-in-repo> <target-path>
# Symlinks target -> source. Backs up an existing real file/dir to *.bak.
# Idempotent: a correct existing symlink is left alone.
link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then err "missing source: $src"; return 1; fi
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then ok "linked $dst"; return 0; fi
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"; warn "backed up existing $dst -> $backup"
  fi
  ln -s "$src" "$dst"; ok "linked $dst -> $src"
}
