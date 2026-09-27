#!/usr/bin/env bash
# Restore the saved editor extensions; settings and keybindings belong to 40-links.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "VS Code extensions"
if has code; then
  vscode=(code)
elif has flatpak && flatpak info com.visualstudio.code >/dev/null 2>&1; then
  vscode=(flatpak run --command=code com.visualstudio.code)
else
  info "VS Code is not installed — skipping extensions"
  exit 0
fi

while IFS= read -r extension; do
  [ -n "$extension" ] || continue
  run "${vscode[@]}" --install-extension "$extension"
done < "$CONFIG_DIR/vscode/extensions.txt"
