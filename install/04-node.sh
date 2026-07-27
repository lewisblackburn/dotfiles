#!/usr/bin/env bash
# Node toolchain via nvm (needed by several LSPs), plus pnpm/corepack.
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "node (nvm)"

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  info "installing nvm..."
  PROFILE=/dev/null bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"
else
  ok "nvm present"
fi

# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

if ! nvm which 20 >/dev/null 2>&1; then
  info "installing Node 20 LTS..."
  nvm install 20
  nvm alias default 20
else
  ok "Node $(nvm version 20) present"
fi

# pnpm via corepack (bundled with node)
if has corepack; then corepack enable >/dev/null 2>&1 && ok "corepack/pnpm enabled" || true; fi

# Node-based LSPs that are Homebrew formulae on macOS but aren't packaged for
# Linux distros — install them into nvm's global prefix instead.
if is_linux; then
  for pkg in vscode-langservers-extracted; do
    if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
      ok "$pkg present"
    else
      spin "npm install -g $pkg..." -- npm install -g "$pkg" \
        && ok "$pkg installed" || warn "$pkg install failed"
    fi
  done
fi
