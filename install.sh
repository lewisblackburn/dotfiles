#!/usr/bin/env bash
# Bootstrap this machine from the dotfiles repo.
#
#   ./install.sh            interactive: pick steps from a menu (fancy with gum)
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

header "Dotfiles bootstrap" "$DOTFILES"

# Offer to install gum up front so the rest of the run is fancy (needs brew).
if has brew && ! has gum && [ "${DOTFILES_YES:-0}" != "1" ]; then
  if ask "Install 'gum' for a nicer installer UI?"; then brew install gum || true; fi
fi

# Discover modules + their one-line descriptions (line 2 comment of each file).
names=(); descs=()
for module in install/[0-9]*.sh; do
  names+=("$(basename "$module" .sh)")
  descs+=("$(sed -n '2s/^# *//p' "$module")")
done

# Decide which modules to run.
selected=""
if [ "${#FILTERS[@]}" -gt 0 ] || [ "${DOTFILES_YES:-0}" = "1" ]; then
  # filters or --yes: select matching (or all) without a menu
  for i in "${!names[@]}"; do
    n="${names[$i]}"
    if [ "${#FILTERS[@]}" -eq 0 ]; then selected+="$n"$'\n'; continue; fi
    for f in "${FILTERS[@]}"; do [[ "$n" == *"$f"* ]] && selected+="$n"$'\n'; done
  done
elif gum_ok; then
  # fancy multi-select menu, everything preselected
  printf '\n'; gum style --foreground 244 "Space toggles · Enter confirms · everything is preselected"
  all="$(IFS=,; echo "${names[*]}")"
  selected="$(gum choose --no-limit --height "$(( ${#names[@]} + 2 ))" \
    --header "Select steps to run:" --selected="$all" "${names[@]}")"
else
  # plain fallback: ask per module
  for i in "${!names[@]}"; do
    if ask "Run ${names[$i]} — ${descs[$i]}?"; then selected+="${names[$i]}"$'\n'; fi
  done
fi

[ -z "$selected" ] && { warn "nothing selected"; exit 0; }

# Run selected modules in numeric order.
for i in "${!names[@]}"; do
  n="${names[$i]}"
  printf '%s\n' "$selected" | grep -qxF "$n" || continue
  header "$n" "${descs[$i]}"
  bash "install/$n.sh"
done

printf '\n'
header "Done" "Restart your terminal (and iTerm2) to pick everything up."
