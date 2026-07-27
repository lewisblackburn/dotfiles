#!/usr/bin/env bash
# GUI / system extras: espanso, plus the per-OS window-manager & input tools.
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Extras (espanso, window manager, ...)"

# espanso — config is tracked and cross-platform; the binary isn't.
# macOS: cask from the Brewfile. Linux: not in the Fedora repos, and the build
# is display-server specific (separate X11 / Wayland packages upstream).
if [ -d "$CONFIG_DIR/espanso" ]; then
  link "$CONFIG_DIR/espanso" "$HOME/.config/espanso"
  if has espanso; then
    if ! espanso status >/dev/null 2>&1; then
      info "registering espanso service..."
      espanso service register >/dev/null 2>&1 || true
      espanso start >/dev/null 2>&1 || true
    fi
    ok "espanso running"
  elif is_linux; then
    warn "espanso not installed — no Fedora package; grab the ${XDG_SESSION_TYPE:-x11} build:"
    info "  https://espanso.org/install/  (config is already linked and will be picked up)"
  fi
fi

if is_macos; then
  # aerospace / karabiner: apps come from the Brewfile. No configs are tracked
  # yet (you were on defaults). Drop configs under config/<tool>/ and add a
  # link line here when you want them versioned.
  info "aerospace, karabiner-elements, android tools, docker-desktop installed via Brewfile"
  info "grant macOS Accessibility/Input-Monitoring permissions on first launch"
else
  # Linux equivalents of the macOS-only tools, for reference — none of these
  # have tracked configs yet, so nothing is installed automatically.
  info "no Linux counterparts configured for: aerospace (tiling WM), karabiner (key remap)"
  info "  tiling:    i3 / sway (Wayland) / hyprland    — dnf install i3 | sway"
  info "  key remap: keyd or input-remapper            — dnf install keyd"
  if has systemctl && has docker && ! systemctl is-active --quiet docker; then
    warn "docker installed but not running — sudo systemctl enable --now docker"
    info "and add yourself to the docker group: sudo usermod -aG docker \$USER (re-login)"
  fi
fi
