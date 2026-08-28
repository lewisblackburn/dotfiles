#!/usr/bin/env bash
# Every symlink this repo owns, from the one list in lib/links.sh.
#
# Your live config paths become symlinks *into* the repo, so editing a config
# edits the repo directly — there is no copy or sync step. A real file already
# sitting at a target is moved to <path>.bak.<timestamp> first.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/links.sh"

log "Symlinks"
links_each link

# Sources that don't exist yet are skipped by links_each — say which, so a
# missing config is visible instead of silently doing nothing.
missing=()
while IFS='|' read -r src _dst; do
  [ -n "$src" ] || continue
  [ -e "$CONFIG_DIR/$src" ] || missing+=("$src")
done < <(dotfiles_links)
[ "${#missing[@]}" -gt 0 ] && info "not tracked (skipped): ${missing[*]}"
exit 0
