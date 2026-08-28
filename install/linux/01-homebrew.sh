#!/usr/bin/env bash
# Homebrew on Linux — the source for CLI tools, same list as macOS.
#
# dnf owns the system layer (00-distro); brew owns user-space CLI tools. That
# split is what lets packages/tools.csv be one list for both operating systems
# instead of a second set of distro package names to keep in sync.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Homebrew (Linuxbrew)"
ensure_brew
