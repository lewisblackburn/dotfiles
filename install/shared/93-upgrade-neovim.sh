#!/usr/bin/env bash
# Upgrade nvim plugins, treesitter parsers and Mason tools.
#
# This rewrites config/nvim/lazy-lock.json, which is tracked — install.sh
# reminds you to commit it once the whole upgrade finishes.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Neovim"
has nvim || { warn "neovim missing"; exit 0; }
[ -e "$HOME/.config/nvim" ] || { warn "the ~/.config/nvim link is missing"; exit 0; }

if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
  # `Lazy! check` fetches updates and reports without installing them.
  nvim --headless "+Lazy! check" +qa 2>&1 | sed 's/^/      /' || true
  exit 0
fi

spin "updating plugins (lazy.nvim)..." -- nvim --headless "+Lazy! sync" +qa \
  || warn "Lazy sync reported issues"
# See install/shared/50-neovim.sh for why this isn't "+TSUpdateSync".
spin "updating treesitter parsers..." -- nvim --headless -c "luafile $DOTFILES/lib/nvim/treesitter-sync.lua" -c qa \
  || warn "treesitter parser update reported issues"
spin "updating Mason tools..." -- nvim --headless "+MasonToolsUpdateSync" +qa \
  || warn "MasonToolsUpdate reported issues"
ok "neovim up to date"

if ! dry && ! git -C "$DOTFILES" diff --quiet -- config/nvim/lazy-lock.json 2>/dev/null; then
  info "lazy-lock.json changed — commit it so other machines get the same versions"
fi
