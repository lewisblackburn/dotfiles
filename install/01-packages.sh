#!/usr/bin/env bash
# Every package for this machine: the Brewfile on both OSes, plus dnf/apt for
# the system layer on Linux.
# platforms: all
#
# Homebrew runs on Linux too, so the Brewfile is the single source of truth for
# CLI tools on both OSes. The native package manager only handles what brew
# shouldn't own: build prerequisites, the login shell, system python, the JDKs
# and the container runtime (see packages/<distro>.txt).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

# Formulae the system package manager owns on Linux instead of brew:
# docker needs a systemd engine, and the JDKs/zsh/python must live in the
# standard system paths for jdtls, chsh and nvim's python provider to find them.
BREW_SKIP_LINUX=(docker docker-compose openjdk openjdk@17 zsh python@3.14)

if is_linux; then log "Packages ($PKG for the system layer, brew for CLI tools)"
else log "Packages (brew)"; fi

# ---------------------------------------------------------------- Homebrew ----
ensure_brew() {
  if has_brew; then
    brew_shellenv
    ok "Homebrew present ($(brew --version | head -1))"
    return 0
  fi
  info "installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew_shellenv || { err "Homebrew installed but not found on PATH"; return 1; }
  ok "Homebrew installed"
}

# Write a platform-appropriate Brewfile to $1.
#
# Both OSes drop the `npm` entries: brew bundle installs those before the node
# formula, so on a machine without node yet they fail outright or land in an
# unwritable global prefix. Module 04 installs them once nvm's node is active.
# Linux additionally drops casks (macOS-only), VS Code extensions when there's
# no `code` on PATH, and anything in BREW_SKIP_LINUX.
brewfile_for_platform() {
  local out="$1" line name skip
  : > "$out"
  while IFS= read -r line; do
    case "$line" in
      'npm '*) continue ;;
    esac
    if is_linux; then
      case "$line" in
        'cask '*)   continue ;;
        'vscode '*) has code || continue ;;
      esac
      if [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
        name="${BASH_REMATCH[1]}"
        for skip in "${BREW_SKIP_LINUX[@]}"; do
          [ "$skip" = "$name" ] && { name=""; break; }
        done
        [ -z "$name" ] && continue
      fi
    fi
    printf '%s\n' "$line" >> "$out"
  done < "$DOTFILES/Brewfile"
}

apply_brewfile() {
  local bf; bf="$(mktemp)"
  trap 'rm -f "$bf"' RETURN
  brewfile_for_platform "$bf"

  local n; n="$(grep -c '^\(brew\|cask\|vscode\) ' "$bf" || true)"
  log "brew bundle — $n entries (safe to re-run)"
  info "npm entries are handled by module 04, once node is set up"
  is_linux && info "skipping casks and: ${BREW_SKIP_LINUX[*]}"

  # brew bundle continues past individual failures and exits non-zero at the
  # end, so a single unavailable formula shouldn't abort the whole install.
  brew bundle --file="$bf" && ok "Brewfile applied" \
    || warn "some Brewfile entries failed (see above) — the rest were installed"
}

# ------------------------------------------------------------ system layer ----
install_system_layer() {
  local manifest
  manifest="$(pkg_manifest)" || {
    err "no packages/$OS_ID.txt (or packages/linux.txt) — copy packages/fedora.txt and adjust names"
    return 1
  }
  pkg_sync
  pkg_install_manifest "$manifest"
}

# Nerd Fonts are casks, which don't exist on Linux — fetch the same two the
# Brewfile installs on macOS. Only fetches what's missing, so a part-finished
# run resumes cleanly.
install_nerd_fonts() {
  local fontdir="$HOME/.local/share/fonts/NerdFonts"
  local base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
  local tmp="${TMPDIR:-/tmp}" f
  local -a need=()
  for f in FiraCode Hack; do
    compgen -G "$fontdir/$f*" >/dev/null || need+=("$f")
  done
  [ "${#need[@]}" -eq 0 ] && { ok "nerd fonts present"; return 0; }
  ask "Download Nerd Fonts (${need[*]})?" || return 0

  mkdir -p "$fontdir"
  for f in "${need[@]}"; do
    if spin "fetching $f Nerd Font..." -- bash -c \
        "curl -fsSL '$base/$f.zip' -o '$tmp/$f.zip' \
         && unzip -oq '$tmp/$f.zip' -d '$fontdir' \
         && rm -f '$tmp/$f.zip'"; then
      ok "$f Nerd Font -> $fontdir"
    else
      warn "$f Nerd Font download failed"
    fi
  done
  has fc-cache && fc-cache -f "$fontdir" >/dev/null 2>&1 && ok "font cache rebuilt"
}

# ---------------------------------------------------------------------------
if is_linux; then
  platform_tested || warn "$OS_ID is untested — trying $PKG anyway"
  install_system_layer
fi

ensure_brew
apply_brewfile

is_linux && install_nerd_fonts
exit 0
