#!/usr/bin/env bash
# Install and apply the shared VS Code Dark 2026 Base24 scheme for Tinty.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"

log "Tinty theme"
if ! has tinty; then
  warn "tinty is missing — run the packages module first"
  exit 0
fi

theme="$DOTFILES/themes/vscode-dark-2026/base24/vscode-dark-2026.yaml"
if [ ! -f "$theme" ]; then
  warn "VS Code Dark 2026 submodule is missing — run: git submodule update --init --recursive"
  exit 0
fi

target="$(tinty config --data-dir-path)/custom-schemes/base24/vscode-dark-2026.yaml"
if dry; then
  info "would link $target -> $theme"
else
  mkdir -p "$(dirname "$target")"
  ln -sfn "$theme" "$target"
  ok "VS Code Dark 2026 scheme linked"
fi

run tinty sync
run tinty build "$(tinty config --data-dir-path)/repos/tinted-tmux"
run tinty apply base24-vscode-dark-2026
