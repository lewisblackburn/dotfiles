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

# ---- platform detection ---------------------------------------------------
# OS_FAMILY  darwin | linux
# OS_ID      macos, or the Linux /etc/os-release ID (fedora, ubuntu, arch, ...)
# OS_LIKE    /etc/os-release ID_LIKE (e.g. "rhel centos fedora"), empty on macOS
# PKG        the *system* package manager: brew (macOS) | dnf | apt | pacman | zypper
# SUDO       "sudo" when needed and available, else empty (already root)
#
# On Linux, Homebrew is a second, supplementary source (see brew_bin/has_brew):
# dnf owns the system layer, brew owns the user-space CLI tools. PKG must stay
# the native manager there even once brew is installed.
case "$(uname -s)" in
  Darwin) OS_FAMILY="darwin"; OS_ID="macos"; OS_LIKE="" ;;
  Linux)
    OS_FAMILY="linux"
    # subshell: don't leak NAME/VERSION/etc. from os-release into our env
    OS_ID="$(. /etc/os-release 2>/dev/null; printf '%s' "${ID:-linux}")"
    OS_LIKE="$(. /etc/os-release 2>/dev/null; printf '%s' "${ID_LIKE:-}")"
    ;;
  *) OS_FAMILY="$(uname -s | tr '[:upper:]' '[:lower:]')"; OS_ID="$OS_FAMILY"; OS_LIKE="" ;;
esac
export OS_FAMILY OS_ID OS_LIKE

PKG=""
if [ "$OS_FAMILY" = "darwin" ]; then
  PKG="brew"                        # bootstrapped by module 01 if not yet present
elif has dnf; then PKG="dnf"
elif has apt-get; then PKG="apt"
elif has pacman; then PKG="pacman"
elif has zypper; then PKG="zypper"
elif has brew; then PKG="brew"      # brew-only Linux box, unusual but workable
fi
export PKG

# brew_bin -> path to brew, checking the standard prefixes as well as PATH, so
# this works in a shell that hasn't run `brew shellenv` yet.
brew_bin() {
  local b
  if has brew; then command -v brew; return 0; fi
  for b in /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew" \
           /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$b" ] && { printf '%s\n' "$b"; return 0; }
  done
  return 1
}
has_brew() { brew_bin >/dev/null 2>&1; }

# Load brew into this shell's environment (PATH, MANPATH, ...) if it exists.
brew_shellenv() {
  local b; b="$(brew_bin)" || return 1
  eval "$("$b" shellenv)"
}

# Each module runs as its own bash process, so do this at source time: once
# module 01 has installed brew, every later module sees brew's bin on PATH.
has brew || brew_shellenv 2>/dev/null || true

SUDO=""
if [ "$(id -u)" != "0" ] && has sudo; then SUDO="sudo"; fi
export SUDO

is_macos()  { [ "$OS_FAMILY" = "darwin" ]; }
is_linux()  { [ "$OS_FAMILY" = "linux" ]; }
# "fedora-ish" = Fedora itself or anything declaring it in ID_LIKE (RHEL, Nobara, ...)
is_fedora() { [ "$OS_ID" = "fedora" ] || [[ " $OS_LIKE " == *" fedora "* ]]; }

# Platforms these scripts are actually exercised on. Anything else runs
# best-effort through the generic $PKG path.
platform_tested() { is_macos || is_fedora; }

# platform_matches "macos linux" | "macos" | "fedora" | "all"
# Used by install.sh to skip modules that don't apply to this machine.
platform_matches() {
  local spec="${1:-all}" tag
  [ "$spec" = "all" ] && return 0
  for tag in $spec; do
    case "$tag" in
      all)     return 0 ;;
      macos)   is_macos && return 0 ;;
      linux)   is_linux && return 0 ;;
      fedora)  is_fedora && return 0 ;;
      *)       [ "$tag" = "$OS_ID" ] && return 0 ;;
    esac
  done
  return 1
}

# ---- packages -------------------------------------------------------------
# Thin wrapper over the native package manager so modules don't branch on OS.

# pkg_installed <name> -> 0 if already installed
pkg_installed() {
  case "$PKG" in
    brew)   brew list --versions "$1" >/dev/null 2>&1 ;;
    dnf)    rpm -q "$1" >/dev/null 2>&1 ;;
    apt)    dpkg -s "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
    zypper) rpm -q "$1" >/dev/null 2>&1 ;;
    *)      return 1 ;;
  esac
}

# pkg_available <name> -> 0 if the repos know about it
pkg_available() {
  case "$PKG" in
    brew)   brew info --formula "$1" >/dev/null 2>&1 ;;
    dnf)    dnf -q info "$1" >/dev/null 2>&1 ;;
    apt)    apt-cache show "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Si "$1" >/dev/null 2>&1 ;;
    zypper) zypper -q info "$1" >/dev/null 2>&1 ;;
    *)      return 1 ;;
  esac
}

# pkg_sync -> refresh repo metadata (no-op where it isn't needed)
pkg_sync() {
  case "$PKG" in
    apt)    spin "apt-get update..." -- $SUDO apt-get update -qq ;;
    pacman) spin "pacman -Sy..."     -- $SUDO pacman -Syy --noconfirm ;;
    *)      : ;;  # dnf/brew refresh on demand
  esac
}

# pkg_install <name>...  -> install one or more packages non-interactively
pkg_install() {
  [ "$#" -eq 0 ] && return 0
  case "$PKG" in
    brew)   brew install "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    apt)    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) $SUDO zypper --non-interactive install "$@" ;;
    *)      err "no supported package manager found"; return 1 ;;
  esac
}

# brewfile_entries <type> -> the names from `<type> "name"` lines in the Brewfile
# (type is brew | cask | vscode | npm | tap).
brewfile_entries() {
  sed -n "s/^$1 \"\([^\"]*\)\".*/\1/p" "$DOTFILES/Brewfile"
}

# pkg_manifest -> path of the package list for this machine, most specific first:
#   packages/<os-id>.txt  ->  packages/<os-family>.txt
pkg_manifest() {
  local f
  for f in "$DOTFILES/packages/$OS_ID.txt" "$DOTFILES/packages/$OS_FAMILY.txt"; do
    [ -f "$f" ] && { printf '%s\n' "$f"; return 0; }
  done
  return 1
}

# pkg_install_manifest <file>
# Manifest format: one package per line, '#' comments, blank lines ignored.
# A leading '?' marks a package as optional — missing ones warn instead of failing.
# Required packages are installed in one batch (fast); if that batch fails we
# retry one-by-one so a single bad name can't sink the whole run.
pkg_install_manifest() {
  local file="$1" line pkg required=() optional=() missing=() failed=()
  [ -f "$file" ] || { err "no package manifest for $OS_ID ($file)"; return 1; }

  while IFS= read -r line; do
    line="${line%%#*}"; line="${line// /}"
    [ -z "$line" ] && continue
    if [ "${line:0:1}" = "?" ]; then optional+=("${line:1}"); else required+=("$line"); fi
  done < "$file"

  info "$(basename "$file"): ${#required[@]} required, ${#optional[@]} optional"

  if [ "${#required[@]}" -gt 0 ]; then
    if ! pkg_install "${required[@]}" >/dev/null 2>&1; then
      warn "batch install failed — retrying individually"
      local log_out
      for pkg in "${required[@]}"; do
        pkg_installed "$pkg" && continue
        log_out="$(pkg_install "$pkg" 2>&1)" && continue
        failed+=("$pkg")
        # Show the manager's own reason — a wrong name and a broken mirror are
        # very different problems, and swallowing the output hides which it is.
        printf '%s\n' "$log_out" | grep -iE 'no match|not found|nothing provides|conflict|error' \
          | head -2 | sed "s/^/      $pkg: /"
      done
    fi
    [ "${#failed[@]}" -eq 0 ] && ok "required packages installed" \
                              || err "failed: ${failed[*]}"
  fi

  for pkg in "${optional[@]}"; do
    pkg_installed "$pkg" && continue
    pkg_install "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done
  [ "${#optional[@]}" -gt 0 ] && { [ "${#missing[@]}" -eq 0 ] \
    && ok "optional packages installed" \
    || warn "unavailable here (skipped): ${missing[*]}"; }
  return 0
}

# gum makes the UI fancy; everything degrades gracefully without it.
gum_ok() { has gum; }

# header "Title" ["subtitle"] -> a bordered banner (gum) or a plain heading.
header() {
  if gum_ok; then
    gum style --border rounded --border-foreground 39 --padding "0 2" --margin "1 0" "$@"
  else
    printf '\n%s\n' "${_c_blue}==>${_c_reset} ${_c_bold}$1${_c_reset}"
    [ -n "${2:-}" ] && info "$2"
  fi
}

# spin "message" -- cmd args...  -> run cmd under a spinner (gum) or plainly.
# Use ONLY for non-interactive commands (a spinner hides their prompts/output).
spin() {
  local msg="$1"; shift; [ "${1:-}" = "--" ] && shift
  if gum_ok; then gum spin --spinner dot --title "$msg" -- "$@"; else info "$msg"; "$@"; fi
}

# ask "Question?" [Y/n default yes]  -> returns 0 for yes.
# Honors DOTFILES_YES=1 (assume yes, for non-interactive runs).
ask() {
  local prompt="$1" default="${2:-Y}" reply
  if [ "${DOTFILES_YES:-0}" = "1" ]; then return 0; fi
  if gum_ok; then
    if [ "$default" = "Y" ]; then gum confirm --default=true  "$prompt"; else gum confirm --default=false "$prompt"; fi
    return $?
  fi
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
