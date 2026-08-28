#!/usr/bin/env bash
# Upgrade things that manage their own updates (gh extensions).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "CLI extensions"
has gh || { info "gh not installed — nothing to do"; exit 0; }

if [ -z "$(gh extension list 2>/dev/null)" ]; then
  ok "no gh extensions installed"
  exit 0
fi

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  gh extension list 2>/dev/null | sed 's/^/      /'
else
  spin "gh extension upgrade --all..." -- gh extension upgrade --all \
    && ok "gh extensions up to date" || warn "gh extension upgrade failed"
fi
exit 0
