#!/usr/bin/env bash
# Upgrade Homebrew formulae and casks.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Homebrew"
has_brew || { warn "Homebrew missing — nothing to upgrade"; exit 0; }
brew_shellenv

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  brew update >/dev/null 2>&1 || true
  out="$(brew outdated --formula 2>/dev/null || true)"
  cout="$(brew outdated --cask --greedy 2>/dev/null || true)"
  [ -n "$out" ]  && { info "outdated formulae:"; printf '%s\n' "$out"  | sed 's/^/      /'; } || ok "formulae up to date"
  [ -n "$cout" ] && { info "outdated casks:";    printf '%s\n' "$cout" | sed 's/^/      /'; } || ok "casks up to date"
  exit 0
fi

spin "brew update..."         -- brew update            || warn "brew update failed"
spin "brew upgrade..."        -- brew upgrade           || warn "some formulae failed to upgrade"
spin "brew upgrade --cask..." -- brew upgrade --cask    || warn "some casks failed to upgrade"
spin "brew cleanup..."        -- brew cleanup           || true
ok "Homebrew up to date"
