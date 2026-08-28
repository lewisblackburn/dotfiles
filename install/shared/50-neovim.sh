#!/usr/bin/env bash
# AstroNvim: bootstrap plugins, treesitter parsers and Mason LSP servers.
#
# The config directory itself is symlinked by 40-links. This module only does
# the expensive one-off bootstrap, which needs node and java from mise — hence
# running after 20-runtimes.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Neovim (AstroNvim)"

has nvim && ok "neovim $(nvim --version | head -1 | awk '{print $2}')" \
         || { warn "neovim missing — run the packages module first"; exit 0; }

if [ ! -e "$HOME/.config/nvim" ]; then
  warn "the ~/.config/nvim link is missing — run: ./install.sh --only 40-links"
  exit 0
fi

if ask "Bootstrap plugins now (Lazy sync + treesitter + Mason)? Takes a few minutes."; then
  spin "syncing plugins (lazy.nvim)..." -- nvim --headless "+Lazy! sync" +qa \
    || warn "Lazy sync reported issues (open nvim to inspect)"
  # Not "+TSUpdateSync": that command no longer exists on the nvim-treesitter
  # branch AstroNvim v6 tracks, and :TSUpdate is async so a headless run exits
  # before any parser compiles. See lib/nvim/treesitter-sync.lua.
  spin "installing treesitter parsers..." -- nvim --headless -c "luafile $DOTFILES/lib/nvim/treesitter-sync.lua" -c qa \
    || warn "treesitter parser install reported issues"
  # Without this the ~22 LSP servers the astrocommunity packs declare install
  # lazily on your first real nvim launch, which is a surprising 2-minute wait.
  spin "installing Mason tools (LSP servers, formatters)..." \
    -- nvim --headless "+MasonToolsInstallSync" +qa \
    || warn "MasonToolsInstall reported issues (check :Mason inside nvim)"
  ok "neovim bootstrapped"
else
  info "skipped — plugins install on first 'nvim' launch instead"
fi
