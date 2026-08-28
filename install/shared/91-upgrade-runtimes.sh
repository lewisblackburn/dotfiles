#!/usr/bin/env bash
# Upgrade mise itself, the runtimes it manages, and the global npm packages.
#
# `mise upgrade` respects the pins in config/mise/config.toml, so java stays on
# temurin-17/21 and node on 20 — it moves them to the newest patch, not the
# newest major. Change a major by editing that file.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"

log "Runtimes (mise)"
has mise || { warn "mise missing — run: ./install.sh --only 20-runtimes"; exit 0; }

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  out="$(mise outdated 2>/dev/null || true)"
  [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/      /' || ok "runtimes up to date"
else
  # self-update only works for a standalone install; brew's copy is upgraded by
  # the platform module, so a failure here is expected and not worth a warning.
  spin "updating mise..." -- mise self-update -y >/dev/null 2>&1 || true
  spin "upgrading runtimes..." -- mise upgrade || warn "some runtimes failed to upgrade"
  spin "pruning unused versions..." -- mise prune -y >/dev/null 2>&1 || true
  ok "runtimes up to date"
  dry || mise ls --current 2>/dev/null | sed 's/^/      /' || true
fi

npm_pkgs=()
while IFS= read -r p; do [ -n "$p" ] && npm_pkgs+=("$p"); done < <(registry_entries npm)
[ "${#npm_pkgs[@]}" -eq 0 ] && exit 0

log "npm globals"
mise exec -- node --version >/dev/null 2>&1 || { warn "no usable node from mise — skipping"; exit 0; }

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  out="$(mise exec -- npm outdated -g --depth=0 2>/dev/null || true)"
  [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/      /' || ok "npm globals up to date"
else
  spin "npm update -g..." -- mise exec -- npm update -g "${npm_pkgs[@]}" \
    && ok "npm globals up to date" \
    || warn "some npm globals failed to update"
fi
