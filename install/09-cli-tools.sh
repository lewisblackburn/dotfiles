#!/usr/bin/env bash
# Config for CLI tools installed by module 01 (lazygit, gh).
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "CLI tools (lazygit, gh)"

link "$CONFIG_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

# gh: link non-secret config only. The auth token (hosts.yml) is NOT in the
# repo — authenticate per machine.
link "$CONFIG_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"
if has gh && ! gh auth status >/dev/null 2>&1; then
  warn "gh not authenticated — run: gh auth login"
else
  has gh && ok "gh authenticated"
fi
