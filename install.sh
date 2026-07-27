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

if [ -z "$PKG" ]; then
  err "no supported package manager found (brew/dnf/apt/pacman/zypper)"; exit 1
fi
if ! platform_tested; then
  warn "$OS_ID is untested — modules run best-effort via $PKG"
fi

header "Dotfiles bootstrap" "$DOTFILES" "$OS_ID · $PKG"

# Offer to install gum up front so the rest of the run is fancy. Only when the
# package manager can already see it — on a fresh Fedora it arrives with the
# Charm repo in module 01, so don't prompt for a guaranteed failure here.
if ! has gum && [ "${DOTFILES_YES:-0}" != "1" ] && pkg_available gum; then
  if ask "Install 'gum' for a nicer installer UI?"; then pkg_install gum || true; fi
fi

# Discover modules: description = line 2 comment, platforms = "# platforms:" header.
# Modules that don't apply to this OS are listed as skipped and never run.
names=(); descs=(); skipped=()
for module in install/[0-9]*.sh; do
  n="$(basename "$module" .sh)"
  d="$(sed -n '2s/^# *//p' "$module")"
  p="$(sed -n '1,8s/^# *platforms: *//p' "$module")"
  if platform_matches "${p:-all}"; then
    names+=("$n"); descs+=("$d")
  else
    skipped+=("$n (${p})")
  fi
done

if [ "${#skipped[@]}" -gt 0 ]; then
  info "not applicable on $OS_ID: ${skipped[*]}"
fi

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
if is_macos; then
  header "Done" "Restart your terminal (and iTerm2) to pick everything up."
else
  header "Done" "Restart your terminal (or log out/in) to pick everything up."
fi
