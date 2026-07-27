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

# Global npm packages, read from the Brewfile's `npm` lines so there's still one
# package list. They run here rather than under `brew bundle` because brew
# installs npm packages before the node formula — on a fresh machine that either
# fails outright or writes to a root-owned prefix. nvm's node avoids both.
log "npm globals (from Brewfile)"
npm_pkgs=()
while IFS= read -r p; do [ -n "$p" ] && npm_pkgs+=("$p"); done < <(brewfile_entries npm)

for pkg in ${npm_pkgs[@]+"${npm_pkgs[@]}"}; do
  # corepack ships with node and is enabled above, not installed from the registry
  [ "$pkg" = "corepack" ] && continue
  if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
    ok "$pkg present"
  else
    spin "installing $pkg..." -- npm install -g "$pkg" \
      && ok "$pkg installed" \
      || warn "$pkg failed (private registry? needs 'npm login')"
  fi
done
