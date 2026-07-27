#!/usr/bin/env bash
# Verify the Java toolchain (JDK 17 + 21 — nvim's jdtls needs both).
# platforms: all
# macOS: Temurin casks from the Brewfile, resolved via /usr/libexec/java_home.
# Linux: distro OpenJDK packages, resolved by globbing /usr/lib/jvm.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Java (17 + 21)"

# jdk_home <major-version> -> prints JAVA_HOME on stdout, non-zero if not found.
jdk_home() {
  local v="$1" d
  if is_macos; then
    /usr/libexec/java_home -v "$v" 2>/dev/null && return 0
    return 1
  fi
  # brew's own openjdk (bottled on Linux), then distro layouts: Fedora/RHEL
  # openjdk, Temurin tarballs, Debian/Arch names.
  local prefix=""
  has_brew && prefix="$(brew --prefix 2>/dev/null || true)"
  for d in ${prefix:+"$prefix/opt/openjdk@$v"} \
           /usr/lib/jvm/java-"$v"-openjdk* /usr/lib/jvm/java-"$v"* \
           /usr/lib/jvm/temurin-"$v"* /usr/lib/jvm/jdk-"$v"* \
           /usr/lib/jvm/*"-$v"-*; do
    if [ -x "$d/bin/javac" ]; then printf '%s\n' "$d"; return 0; fi
  done
  return 1
}

# Per-OS hint for a missing JDK. On Linux brew is the reliable route: it's
# bottled for both arches, and distro package names vary between releases.
jdk_hint() {
  local v="$1"
  if is_macos; then echo "brew install --cask temurin@$v"
  else              echo "brew install openjdk@$v"
  fi
}

check_jdk() {
  local v="$1" home
  if home="$(jdk_home "$v")"; then
    ok "JDK $v -> $home"
  else
    warn "JDK $v not found. Install with: $(jdk_hint "$v")"
  fi
}
check_jdk 17
check_jdk 21

info "jdtls runs on 21 and compiles projects against 17 (see config/nvim/lua/plugins/jdtls.lua)"
