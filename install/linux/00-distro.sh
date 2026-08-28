#!/usr/bin/env bash
# Distro system layer — the packages Homebrew shouldn't own on Linux.
#
# Picks a distro profile from install/linux/distros/ and runs it. Fedora is the
# only tested one today; the chooser exists so adding Debian or Arch is a matter
# of dropping in a sibling script, not editing this file.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/distros"

log "Linux distro layer"

available() { for f in "$DISTRO_DIR"/*.sh; do [ -e "$f" ] && basename "$f" .sh; done; }

# Resolution order: explicit --distro, then /etc/os-release (ID, then ID_LIKE),
# then ask. Never guess silently — a wrong package-name set fails confusingly.
choose_distro() {
  local id

  if [ -n "${DOTFILES_DISTRO:-}" ]; then
    if [ -f "$DISTRO_DIR/$DOTFILES_DISTRO.sh" ]; then printf '%s\n' "$DOTFILES_DISTRO"; return 0; fi
    err "no distro profile '$DOTFILES_DISTRO' (have: $(available | tr '\n' ' '))"
    return 1
  fi

  if [ -f "$DISTRO_DIR/$OS_ID.sh" ]; then printf '%s\n' "$OS_ID"; return 0; fi
  for id in $OS_LIKE; do
    [ -f "$DISTRO_DIR/$id.sh" ] && { printf '%s\n' "$id"; return 0; }
  done

  warn "no profile for '$OS_ID' (ID_LIKE: ${OS_LIKE:-none})" >&2
  local opts; opts="$(available)"
  if [ -z "$opts" ]; then err "no distro profiles at all in $DISTRO_DIR"; return 1; fi
  if [ "${DOTFILES_YES:-0}" = "1" ]; then
    err "can't pick a distro non-interactively — pass --distro <id> (have: $(echo "$opts" | tr '\n' ' '))"
    return 1
  fi
  if gum_ok; then
    gum choose --header "Which distro profile should I use?" $opts
  else
    info "available profiles: $(echo "$opts" | tr '\n' ' ')" >&2
    read -r -p "$(printf 'distro profile: ')" id
    printf '%s\n' "$id"
  fi
}

distro="$(choose_distro)" || exit 1
[ -f "$DISTRO_DIR/$distro.sh" ] || { err "no profile '$distro'"; exit 1; }

info "using profile: $distro ($PKG)"
platform_tested || warn "$OS_ID is untested — running best-effort via $PKG"

bash "$DISTRO_DIR/$distro.sh"
