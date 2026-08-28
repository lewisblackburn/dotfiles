#!/usr/bin/env bash
# Module discovery and selection.
#
# Modules live in two directories and are merged into one ordered run:
#
#   install/shared/      OS-agnostic — runs on macOS, Fedora and WSL alike
#   install/<platform>/  macos | linux — the platform-specific half
#
# Ordering is the numeric filename prefix, so reading `ls install/*/` tells you
# the whole sequence. Bands:
#
#   0x  platform bootstrap (package manager, distro system layer)
#   1x  packages
#   2x  runtimes (mise)
#   3x  shell
#   4x  symlinks
#   5x  editor
#   6x  cli tools
#   7x  platform extras (GUI, fonts, system prefs)
#   9x  upgrade — never part of a normal install; see --upgrade
#
# A module's one-line description is the comment on line 2 of the file, the
# same convention the old flat installer used.

# The platform directory for this machine.
runner_platform_dir() {
  if is_macos; then printf '%s\n' "$DOTFILES/install/macos"
  else printf '%s\n' "$DOTFILES/install/linux"; fi
}

# runner_modules [upgrade]
# Emits "<name>|<path>|<description>" in run order. With the argument "upgrade"
# it emits only the 9x modules; otherwise it emits everything except them.
runner_modules() {
  local mode="${1:-install}" dir f name num desc
  {
    for dir in "$DOTFILES/install/shared" "$(runner_platform_dir)"; do
      [ -d "$dir" ] || continue
      for f in "$dir"/[0-9]*.sh; do
        [ -e "$f" ] || continue
        name="$(basename "$f" .sh)"
        num="${name%%-*}"
        case "$mode" in
          upgrade) [ "${num:0:1}" = "9" ] || continue ;;
          *)       [ "${num:0:1}" = "9" ] && continue ;;
        esac
        desc="$(sed -n '2s/^# *//p' "$f")"
        printf '%s|%s|%s|%s\n' "$num" "$name" "$f" "$desc"
      done
    done
  } | sort -t'|' -k1,1n -k2,2 | cut -d'|' -f2-
}

# runner_select "<modules>" "<filters>" "<only>" "<skip>"
# Prints the names to run, one per line, in the order given by runner_modules.
#
#   filters  positional args (substring match, the existing `./install.sh 06` form)
#   only     comma-separated names/numbers — same matching, from --only
#   skip     comma-separated names/numbers to remove, from --skip
#
# With no filters and no --yes this shows the gum multi-select (everything
# preselected), falling back to a yes/no prompt per module without gum.
runner_select() {
  local modules="$1" filters="$2" only="$3" skip="$4"
  local names=() descs=() name desc sel="" want f

  while IFS='|' read -r name _path desc; do
    [ -n "$name" ] || continue
    names+=("$name"); descs+=("$desc")
  done <<< "$modules"

  [ "${#names[@]}" -eq 0 ] && return 0

  # --only / positional filters narrow the set before any prompting.
  want="$filters"
  [ -n "$only" ] && want="$want ${only//,/ }"

  if [ -n "${want// /}" ] || [ "${DOTFILES_YES:-0}" = "1" ]; then
    for name in "${names[@]}"; do
      if [ -z "${want// /}" ]; then sel+="$name"$'\n'; continue; fi
      for f in $want; do
        case "$name" in *"$f"*) sel+="$name"$'\n'; break ;; esac
      done
    done
  elif gum_ok; then
    printf '\n'
    gum style --foreground 244 "Space toggles · Enter confirms · everything is preselected"
    local all; all="$(IFS=,; echo "${names[*]}")"
    sel="$(gum choose --no-limit --height "$(( ${#names[@]} + 2 ))" \
      --header "Select steps to run:" --selected="$all" "${names[@]}")"
  else
    local i
    for i in "${!names[@]}"; do
      if ask "Run ${names[$i]} — ${descs[$i]}?"; then sel+="${names[$i]}"$'\n'; fi
    done
  fi

  # --skip removes from whatever survived.
  if [ -n "$skip" ]; then
    local kept="" s drop
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      drop=0
      for s in ${skip//,/ }; do
        case "$name" in *"$s"*) drop=1; break ;; esac
      done
      [ "$drop" = "0" ] && kept+="$name"$'\n'
    done <<< "$sel"
    sel="$kept"
  fi

  printf '%s' "$sel"
}

# runner_run "<modules>" "<selected names>"
# Runs each selected module in order, as its own bash process (so a module that
# puts something new on PATH is picked up by the next one via common.sh).
runner_run() {
  local modules="$1" selected="$2" name path desc rc=0
  # The module list is fed in on fd 3, not stdin. Modules run real commands
  # (`brew bundle`, `code --install-extension`) that read stdin themselves; with
  # the list on stdin the first such command drains it and every later module is
  # silently skipped. Modules still get the terminal on fd 0 so their prompts work.
  while IFS='|' read -r name path desc <&3; do
    [ -n "$name" ] || continue
    printf '%s\n' "$selected" | grep -qxF "$name" || continue
    header "$name" "$desc"
    if bash "$path"; then :; else
      rc=1; err "$name failed (continuing — re-run just this step with: ./install.sh --only $name)"
    fi
  done 3<<< "$modules"
  return $rc
}
