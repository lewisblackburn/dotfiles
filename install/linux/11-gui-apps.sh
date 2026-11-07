#!/usr/bin/env bash
# GUI apps with no brew or dnf package on Linux: Flathub apps and vendor installers.
#
# Renders the flatpak: and installer: cells of the fedora column. On macOS the
# same rows are casks; casks don't exist on Linux, so these need their own path.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"

registry_category_enabled gui || exit 0

log "GUI apps"

# ---- Flathub, installed per user so no sudo is needed ----------------------
apps=()
while IFS= read -r a; do [ -n "$a" ] && apps+=("$a"); done < <(registry_entries flatpak)
if [ "${#apps[@]}" -gt 0 ]; then
  if ! has flatpak; then
    warn "flatpak missing, so skipping: ${apps[*]} (install it with: $PKG install flatpak)"
  else
    run flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    for a in "${apps[@]}"; do
      if flatpak info "$a" >/dev/null 2>&1; then
        ok "$a already installed"
      elif spin "installing $a..." -- flatpak install --user -y --noninteractive flathub "$a"; then
        ok "$a installed"
      else
        warn "$a failed to install"
      fi
    done
  fi
fi

# ---- vendor install scripts, one case per name -----------------------------
while IFS= read -r name; do
  [ -n "$name" ] || continue
  case "$name" in
    zed)
      # The official script is Zed's recommended Linux install; the Flathub
      # build is community run and its sandbox gets in the way of language servers.
      if has zed || [ -x "$HOME/.local/bin/zed" ]; then
        ok "zed already installed"
      elif spin "installing zed..." -- bash -c 'curl -fsSL https://zed.dev/install.sh | sh'; then
        ok "zed installed to ~/.local/bin/zed"
      else
        warn "zed failed to install"
      fi ;;
    *) warn "no installer known for '$name'; add a case to install/linux/11-gui-apps.sh" ;;
  esac
done < <(registry_entries installer)
exit 0
