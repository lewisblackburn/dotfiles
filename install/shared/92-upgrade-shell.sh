#!/usr/bin/env bash
# Upgrade oh-my-zsh and its custom plugins.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Shell (oh-my-zsh)"
[ -d "$HOME/.oh-my-zsh" ] || { warn "oh-my-zsh not installed"; exit 0; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  report() {
    local dir="$1" name behind
    name="$(basename "$dir")"
    git -C "$dir" fetch --quiet 2>/dev/null || { warn "$name: fetch failed"; return; }
    behind="$(git -C "$dir" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)"
    [ "$behind" -gt 0 ] && info "$name: $behind commits behind" || ok "$name up to date"
  }
  report "$HOME/.oh-my-zsh"
  for d in "$ZSH_CUSTOM"/plugins/*/; do [ -d "$d/.git" ] && report "${d%/}"; done
  exit 0
fi

# `omz update` is the supported path; it handles the repo's own release notes.
if has omz; then
  spin "omz update..." -- omz update >/dev/null 2>&1 || warn "omz update failed"
else
  spin "updating oh-my-zsh..." -- git -C "$HOME/.oh-my-zsh" pull --ff-only --quiet \
    || warn "oh-my-zsh pull failed"
fi
ok "oh-my-zsh up to date"

for d in "$ZSH_CUSTOM"/plugins/*/; do
  [ -d "$d/.git" ] || continue
  name="$(basename "${d%/}")"
  spin "updating $name..." -- git -C "${d%/}" pull --ff-only --quiet \
    && ok "$name up to date" || warn "$name pull failed"
done
