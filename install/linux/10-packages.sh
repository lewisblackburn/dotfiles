#!/usr/bin/env bash
# All Linux packages: brew formulae from the registry, plus its dnf rows.
#
# Same packages/tools.csv as macOS — this module renders the fedora column.
# Casks are macOS-only and simply have no cell here, so nothing needs filtering.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"

log "Packages"

# ---- the handful the registry routes to the system package manager --------
# (zsh must come from a system path for chsh; podman needs systemd.)
dnf_pkgs=()
while IFS= read -r p; do [ -n "$p" ] && dnf_pkgs+=("$p"); done < <(registry_entries dnf)
if [ "${#dnf_pkgs[@]}" -gt 0 ]; then
  info "$PKG: ${dnf_pkgs[*]}"
  pkg_install "${dnf_pkgs[@]}" >/dev/null 2>&1 && ok "system packages installed" \
    || warn "some system packages failed: ${dnf_pkgs[*]}"
fi

# ---- everything else ------------------------------------------------------
if ! has_brew; then err "Homebrew missing — run: ./install.sh --only 01-homebrew"; exit 1; fi
brew_shellenv
brew_apply_registry
