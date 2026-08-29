#!/usr/bin/env bash
# Ghostty's Fedora COPR repository, enabled before the normal package module.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"
source "$DOTFILES/lib/registry.sh"

registry_category_enabled gui || exit 0

log "Ghostty repository"

if ! is_fedora; then
  warn "Ghostty is only automated for Fedora; install it with this distro's package manager"
  exit 0
fi

if dry; then
  info "would enable COPR: scottames/ghostty"
  exit 0
fi

if dnf copr list --enabled 2>/dev/null | grep -qx 'scottames/ghostty'; then
  ok "COPR scottames/ghostty already enabled"
else
  run $SUDO dnf copr enable -y scottames/ghostty
  ok "COPR scottames/ghostty enabled"
fi
