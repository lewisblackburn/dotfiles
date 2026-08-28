#!/usr/bin/env bash
# Upgrade the distro system layer, then Homebrew.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "System packages ($PKG)"

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  case "$PKG" in
    dnf)    $SUDO dnf -q check-update 2>/dev/null | sed 's/^/      /' || true ;;
    apt)    $SUDO apt-get -qq update >/dev/null 2>&1 || true
            apt list --upgradable 2>/dev/null | tail -n +2 | sed 's/^/      /' ;;
    pacman) pacman -Qu 2>/dev/null | sed 's/^/      /' || true ;;
    zypper) $SUDO zypper -q list-updates 2>/dev/null | sed 's/^/      /' || true ;;
  esac
else
  case "$PKG" in
    dnf)    run $SUDO dnf upgrade --refresh -y ;;
    apt)    run_sh "$SUDO apt-get update -qq && DEBIAN_FRONTEND=noninteractive $SUDO apt-get upgrade -y" ;;
    pacman) run $SUDO pacman -Syu --noconfirm ;;
    zypper) run $SUDO zypper --non-interactive update ;;
    *)      warn "no known upgrade command for '$PKG'" ;;
  esac
  ok "system packages up to date"
fi

log "Homebrew"
has_brew || { warn "Homebrew missing — nothing to upgrade"; exit 0; }
brew_shellenv

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  brew update >/dev/null 2>&1 || true
  out="$(brew outdated --formula 2>/dev/null || true)"
  [ -n "$out" ] && { info "outdated formulae:"; printf '%s\n' "$out" | sed 's/^/      /'; } || ok "formulae up to date"
  exit 0
fi

spin "brew update..."  -- brew update  || warn "brew update failed"
spin "brew upgrade..." -- brew upgrade || warn "some formulae failed to upgrade"
spin "brew cleanup..." -- brew cleanup || true
ok "Homebrew up to date"
