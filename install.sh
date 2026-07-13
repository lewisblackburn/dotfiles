#!/usr/bin/env bash
# Bootstrap this machine from the dotfiles repo.
#
#   ./install.sh            interactive walkthrough (asks before each module)
#   ./install.sh --yes      run everything non-interactively
#   ./install.sh 06 08      run only the modules whose number/name matches
#
# Safe to re-run: every module is idempotent (see README).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source "lib/common.sh"

if [ "${1:-}" = "--yes" ] || [ "${1:-}" = "-y" ]; then
  export DOTFILES_YES=1; shift
fi
FILTERS=("$@")

if ! is_macos; then err "these scripts target macOS"; exit 1; fi

printf '\n%s\n' "${_c_bold}Dotfiles bootstrap${_c_reset} — ${DOTFILES}"
printf '%s\n\n' "Each step asks first. Enter = yes. Ctrl-C to bail anytime."

matches() { # $1 = module filename; true if no filters or any filter substring-matches
  [ "${#FILTERS[@]}" -eq 0 ] && return 0
  local f; for f in "${FILTERS[@]}"; do [[ "$1" == *"$f"* ]] && return 0; done
  return 1
}

for module in install/[0-9]*.sh; do
  name="$(basename "$module" .sh)"
  matches "$name" || continue
  printf '\n'
  if ask "Run ${_c_bold}${name}${_c_reset}?"; then
    bash "$module"
  else
    info "skipped $name"
  fi
done

printf '\n%s\n' "${_c_green}${_c_bold}Done.${_c_reset}"
info "Restart your terminal (and iTerm2) to pick everything up."
