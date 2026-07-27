#!/usr/bin/env bash
# AstroNvim config: symlink it, then let lazy.nvim install plugins + parsers.
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Neovim (AstroNvim)"

has nvim && ok "neovim $(nvim --version | head -1 | awk '{print $2}')" \
         || warn "neovim missing (should come from module 01)"

# Whole config dir is one symlink -> edits are live in the repo.
link "$CONFIG_DIR/nvim" "$HOME/.config/nvim"

if ask "Bootstrap plugins now (headless Lazy sync + TSUpdate)? Takes a minute."; then
  spin "syncing plugins (lazy.nvim)..." -- nvim --headless "+Lazy! sync" +qa \
    || warn "Lazy sync reported issues (open nvim to inspect)"
  spin "installing treesitter parsers..." -- nvim --headless "+TSUpdateSync" +qa \
    || warn "TSUpdate reported issues"
  ok "neovim bootstrapped"
else
  info "skipped — plugins will install on first 'nvim' launch"
fi
