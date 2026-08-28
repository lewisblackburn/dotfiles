#!/usr/bin/env bash
# Desktop extras: espanso, and the Linux counterparts of the macOS-only apps.
#
# Nothing here installs automatically — these are display-server and
# window-manager specific choices, and none of them have tracked configs yet.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Desktop extras"

# espanso: the config is tracked and cross-platform (linked by 40-links); the
# binary isn't packaged for Fedora and the build is display-server specific.
if has espanso; then
  if ! espanso status >/dev/null 2>&1; then
    run_sh 'espanso service register >/dev/null 2>&1 || true'
    run_sh 'espanso start >/dev/null 2>&1 || true'
  fi
  ok "espanso running"
else
  warn "espanso not installed — no Fedora package; grab the ${XDG_SESSION_TYPE:-x11} build:"
  info "  https://espanso.org/install/  (your config is already linked)"
fi

# Counterparts to the macOS casks, for reference. See packages/tools.csv — these
# are exactly the rows `./install.sh --coverage` reports as macOS-only.
info "no Linux counterparts configured for aerospace (tiling WM) or karabiner (key remap):"
info "  tiling:    i3 / sway (Wayland) / hyprland   — dnf install i3 sway"
info "  key remap: keyd or input-remapper           — dnf install keyd"

if has podman; then
  ok "podman present (podman-docker adds a 'docker' CLI shim)"
else
  info "  containers: dnf install podman podman-docker"
fi
exit 0
