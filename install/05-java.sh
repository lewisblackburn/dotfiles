#!/usr/bin/env bash
# Verify the Java toolchain (Temurin 17 + 21 come from the Brewfile casks).
# nvim's jdtls resolves these dynamically via /usr/libexec/java_home.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Java (17 + 21)"

check_jdk() {
  local v="$1" home
  if home="$(/usr/libexec/java_home -v "$v" 2>/dev/null)"; then
    ok "JDK $v -> $home"
  else
    warn "JDK $v not found. Install with: brew install --cask temurin@$v"
  fi
}
check_jdk 17
check_jdk 21

info "jdtls runs on 21 and compiles projects against 17 (see config/nvim/lua/plugins/jdtls.lua)"
