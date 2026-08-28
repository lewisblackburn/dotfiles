#!/usr/bin/env bash
# Homebrew — the package manager everything else on macOS comes from.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Homebrew"
ensure_brew
