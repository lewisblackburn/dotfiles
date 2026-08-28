#!/usr/bin/env bash
# Fedora system layer: Homebrew's build prerequisites, system python for nvim,
# fontconfig, and container runtime setup.
#
# Deliberately short. A package belongs here only if brew shouldn't own it —
# everything else lives in packages/tools.csv like it does on macOS. The list
# itself is packages/fedora.txt.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/lib/common.sh"

log "Fedora system layer (dnf)"

manifest="$(pkg_manifest)" || { err "no packages/$OS_ID.txt or packages/linux.txt"; exit 1; }
pkg_sync
pkg_install_manifest "$manifest"

# ---- containers -----------------------------------------------------------
# Installing podman isn't enough to use it: rootless podman needs the socket
# service running for anything speaking the Docker API (testcontainers, the
# docker-maven-plugin) to find it.
if has podman; then
  if dry; then
    info "would enable the rootless podman socket"
  elif systemctl --user is-enabled podman.socket >/dev/null 2>&1; then
    ok "podman socket enabled"
  else
    if ask "Enable the rootless podman socket (Docker API compatibility)?"; then
      systemctl --user enable --now podman.socket >/dev/null 2>&1 \
        && ok "podman socket enabled" \
        || warn "couldn't enable podman.socket (no systemd user session?)"
      info "point Docker-aware tools at it with:"
      info "  export DOCKER_HOST=unix://\$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  fi
fi
exit 0
