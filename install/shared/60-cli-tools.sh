#!/usr/bin/env bash
# Check the CLI tools whose configs 40-links installed are actually present.
#
# Configs are linked whether or not the binary made it; this module is what
# tells you when the two disagree, rather than you finding out at the prompt.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "CLI tools"

check() {
  local bin="$1" ver="$2"
  if has "$bin"; then ok "$bin $(eval "$ver" 2>/dev/null || true)"
  else warn "$bin missing — run the packages module"; fi
}
check starship 'starship --version | head -1 | awk "{print \$2}"'
check lazygit  'lazygit --version | head -1 | sed -E "s/.*version=([^,]*).*/\1/"'
check tmux     'tmux -V | awk "{print \$2}"'
check gh       'gh --version | head -1 | awk "{print \$3}"'
check zoxide   'zoxide --version | awk "{print \$2}"'
check fzf      'fzf --version | awk "{print \$1}"'
check rg       'rg --version | head -1 | awk "{print \$2}"'
check delta    'delta --version | awk "{print \$2}"'

# gh's auth token (hosts.yml) is deliberately not in the repo — it's per machine.
if has gh; then
  if gh auth status >/dev/null 2>&1; then ok "gh authenticated"
  else warn "gh not authenticated — run: gh auth login"; fi
fi
exit 0
