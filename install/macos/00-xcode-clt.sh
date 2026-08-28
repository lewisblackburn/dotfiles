#!/usr/bin/env bash
# Xcode Command Line Tools — git, clang and the headers Homebrew builds against.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Xcode Command Line Tools"

if xcode-select -p >/dev/null 2>&1; then
  ok "installed ($(xcode-select -p))"
  exit 0
fi

if dry; then info "would run: xcode-select --install"; exit 0; fi

info "launching the installer — accept the GUI prompt, then re-run this script"
xcode-select --install 2>/dev/null || true
warn "waiting for the Command Line Tools install to finish..."
until xcode-select -p >/dev/null 2>&1; do sleep 10; done
ok "Command Line Tools installed"
