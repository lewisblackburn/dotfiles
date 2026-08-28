#!/usr/bin/env bash
# Bootstrap or maintain this machine from the dotfiles repo.
#
# Modules live in install/shared/ plus install/<macos|linux>/ and run in
# filename-number order. See lib/runner.sh for the numbering bands.
#
# Safe to re-run: every module is idempotent. `install.sh` provisions structure;
# `install.sh --upgrade` is the separate, explicit action that moves versions.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source "lib/common.sh"
source "lib/registry.sh"
source "lib/links.sh"
source "lib/runner.sh"

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options] [module-filter...]

  ./install.sh                    interactive menu (everything preselected)
  ./install.sh --yes              run everything, no prompts
  ./install.sh 50 60              run only modules matching "50" or "60"

Selection
  --only a,b        run only these modules (name or number, substring match)
  --skip a,b        run everything except these
  --profile P       full (default) | cli | minimal — which tool categories
  --no-gui          skip GUI apps, fonts and VS Code extensions (WSL/headless)
  --distro ID       force a Linux distro profile instead of auto-detecting

Actions (each exits without running an install)
  --list            list the modules for this machine
  --coverage        report tools available on one platform but not the other
  --doctor          verify this machine matches the repo; non-zero on drift
  --upgrade         update packages, runtimes, plugins — see --outdated first
  --outdated        report what an --upgrade would change; changes nothing
  --unlink          remove the symlinks this repo owns, restoring backups

Behaviour
  -y, --yes         assume yes to every prompt
  -n, --dry-run     print what would happen; change nothing
  -v, --verbose     show command output instead of a spinner
      --no-pull     with --upgrade: don't git pull the dotfiles repo first
  -h, --help        this message
USAGE
}

ACTION="install"
FILTERS=(); ONLY=""; SKIP=""; NO_PULL=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -y|--yes)     export DOTFILES_YES=1 ;;
    -n|--dry-run) export DRY_RUN=1 ;;
    -v|--verbose) export VERBOSE=1 ;;
    --no-pull)    NO_PULL=1 ;;
    --only)       ONLY="${2:?--only needs a value}"; shift ;;
    --only=*)     ONLY="${1#*=}" ;;
    --skip)       SKIP="${2:?--skip needs a value}"; shift ;;
    --skip=*)     SKIP="${1#*=}" ;;
    --profile)    export PROFILE="${2:?--profile needs a value}"; shift ;;
    --profile=*)  export PROFILE="${1#*=}" ;;
    --distro)     export DOTFILES_DISTRO="${2:?--distro needs a value}"; shift ;;
    --distro=*)   export DOTFILES_DISTRO="${1#*=}" ;;
    --no-gui)     export REGISTRY_NO_GUI=1 ;;
    --list)       ACTION="list" ;;
    --coverage)   ACTION="coverage" ;;
    --doctor)     ACTION="doctor" ;;
    --upgrade)    ACTION="upgrade" ;;
    --outdated)   ACTION="upgrade"; export OUTDATED_ONLY=1 ;;
    --unlink)     ACTION="unlink" ;;
    -h|--help)    usage; exit 0 ;;
    -*)           err "unknown option: $1"; usage >&2; exit 2 ;;
    *)            FILTERS+=("$1") ;;
  esac
  shift
done

# Validate the profile early — registry_categories is what would fail otherwise,
# deep inside a module, after the machine has already been half-changed.
registry_categories >/dev/null || exit 2

# ---------------------------------------------------------------- actions ----
action_list() {
  local mode="$1" name path desc
  header "Modules" "$OS_ID · install/shared + install/$(basename "$(runner_platform_dir)")"
  while IFS='|' read -r name path desc; do
    [ -n "$name" ] || continue
    printf '  %-26s %s\n' "$name" "$desc"
    printf '  %-26s %s\n' "" "${_c_blue}${path#"$DOTFILES/"}${_c_reset}"
  done <<< "$(runner_modules "$mode")"
}

action_coverage() {
  header "Tool coverage" "packages/tools.csv"
  local gaps; gaps="$(registry_gaps)"
  if [ -z "$gaps" ]; then
    ok "every tool is available on both macOS and Fedora"
  else
    printf '%s\n' "$gaps" | sed 's/^/  /'
    printf '\n'
    info "$(printf '%s\n' "$gaps" | grep -c .) of $(registry_rows | grep -c .) rows differ between platforms"
    info "these are expected only where the note explains why — anything else is drift"
  fi
}

action_doctor() {
  local fails=0
  header "Doctor" "$OS_ID · profile ${PROFILE:-full}"

  log "Symlinks"
  check_link() {
    local src="$1" dst="$2"
    if [ ! -L "$dst" ]; then
      if [ -e "$dst" ]; then err "$(tildify "$dst") is a real file, not a link into the repo"
      else err "$(tildify "$dst") missing"; fi
      fails=$((fails + 1))
    elif [ "$(readlink "$dst")" != "$src" ]; then
      err "$(tildify "$dst") -> $(readlink "$dst") (expected $src)"
      fails=$((fails + 1))
    else
      ok "$(tildify "$dst")"
    fi
  }
  links_each check_link

  log "Packages"
  # Checked through the package manager rather than by looking for a binary:
  # formula names and binary names differ often enough (ripgrep/rg, bottom/btm,
  # git-delta/delta) that a PATH check would report false failures.
  local missing=() p
  if has_brew; then
    brew_shellenv
    # fd 3 again: `brew list` is a child inside the loop (see lib/runner.sh).
    while IFS= read -r p <&3; do
      [ -n "$p" ] || continue
      brew list --versions "$p" >/dev/null 2>&1 || missing+=("$p")
    done 3< <(registry_entries brew)
  else
    warn "Homebrew not installed — skipping formula check"
  fi
  while IFS= read -r p <&3; do
    [ -n "$p" ] || continue
    pkg_installed "$p" || missing+=("$p")
  done 3< <(registry_entries dnf)
  if [ "${#missing[@]}" -eq 0 ]; then ok "all registry packages installed"
  else err "not installed: ${missing[*]}"; fails=$((fails + 1)); fi

  log "Runtimes"
  if has mise; then
    local installed; installed="$(mise ls --installed 2>/dev/null || true)"
    local rt tool ver rt_missing=()
    while IFS= read -r rt <&3; do
      [ -n "$rt" ] || continue
      # "java@temurin-21" -> tool "java", version prefix "temurin-21". Both must
      # match: two JDKs are pinned, so checking the tool alone would pass with
      # only one of them installed.
      tool="${rt%%@*}"; ver="${rt#*@}"
      [ "$ver" = "latest" ] && ver=""
      printf '%s\n' "$installed" | awk -v t="$tool" -v v="$ver" \
        '$1 == t && (v == "" || index($2, v) == 1) { found = 1 } END { exit !found }' \
        || rt_missing+=("$rt")
    done 3< <(registry_entries mise)
    if [ "${#rt_missing[@]}" -eq 0 ]; then ok "mise runtimes installed"
    else err "mise missing: ${rt_missing[*]}"; fails=$((fails + 1)); fi
    [ -n "${JAVA_HOME:-}" ] && ok "JAVA_HOME=$JAVA_HOME" \
                            || warn "JAVA_HOME unset (start a new shell — .zshrc activates mise)"
  else
    err "mise not installed — no runtimes are managed"; fails=$((fails + 1))
  fi

  log "Shell"
  case "${SHELL:-}" in
    */zsh) ok "default shell is zsh" ;;
    *)     warn "default shell is ${SHELL:-unset}, not zsh" ;;
  esac
  [ -d "$HOME/.nvm" ] && warn "found ~/.nvm — mise owns node now; that directory is safe to delete"
  [ -d "$HOME/.oh-my-zsh" ] && ok "oh-my-zsh present" \
                            || { err "oh-my-zsh missing"; fails=$((fails + 1)); }

  printf '\n'
  if [ "$fails" -eq 0 ]; then header "Doctor: clean" "this machine matches the repo"; return 0; fi
  header "Doctor: $fails problem(s)" "re-run the matching module to fix"
  return 1
}

action_unlink() {
  header "Unlink" "removing the symlinks this repo owns"
  local removed=0
  unlink_one() {
    local src="$1" dst="$2" backup
    [ -L "$dst" ] || return 0
    [ "$(readlink "$dst")" = "$src" ] || { warn "$(tildify "$dst") points elsewhere — left alone"; return 0; }
    run rm -f "$dst"; removed=$((removed + 1))
    # Restore the newest backup link() made, if there is one.
    backup="$(ls -1d "$dst".bak.* 2>/dev/null | sort | tail -1 || true)"
    if [ -n "$backup" ]; then run mv "$backup" "$dst"; ok "$(tildify "$dst") restored from $(basename "$backup")"
    else ok "$(tildify "$dst") removed"; fi
  }
  if ! ask "Remove all dotfiles symlinks from this machine?" N; then info "aborted"; return 0; fi
  links_each unlink_one
  info "$removed link(s) removed — the repo itself is untouched"
}

action_upgrade() {
  local modules selected
  if [ "${OUTDATED_ONLY:-0}" = "1" ]; then
    header "Outdated" "$OS_ID · reporting only, nothing will change"
  else
    header "Upgrade" "$OS_ID · moving packages, runtimes and plugins forward"
  fi

  # Upgrade against the current config, not a stale checkout.
  if [ "$NO_PULL" = "0" ] && [ "${OUTDATED_ONLY:-0}" != "1" ]; then
    log "Dotfiles repo"
    if [ -n "$(git -C "$DOTFILES" status --porcelain)" ]; then
      warn "working tree is dirty — skipping git pull"
    else
      run git -C "$DOTFILES" pull --ff-only && ok "repo up to date" \
        || warn "git pull failed (diverged? try: dot reset)"
    fi
  fi

  modules="$(runner_modules upgrade)"
  selected="$(runner_select "$modules" "${FILTERS[*]:-}" "$ONLY" "$SKIP")"
  [ -z "$selected" ] && { warn "nothing selected"; return 0; }
  runner_run "$modules" "$selected" || true

  [ "${OUTDATED_ONLY:-0}" = "1" ] && { printf '\n'; header "Done" "run --upgrade to apply"; return 0; }

  printf '\n'
  # lazy-lock.json is tracked, so an upgrade that changed plugin versions leaves
  # the repo dirty on purpose — committing it is what pins other machines.
  if ! dry && [ -n "$(git -C "$DOTFILES" status --porcelain)" ]; then
    info "the upgrade changed tracked files:"
    git -C "$DOTFILES" status --short | sed 's/^/      /'
    if ask "Commit and push them?"; then
      run_sh "cd '$DOTFILES' && git add -A && git commit -q -m 'upgrade: $(date +%Y-%m-%d)' && git push"
      ok "pushed"
    else
      info "commit later with:  dot push \"upgrade: $(date +%Y-%m-%d)\""
    fi
  fi
  header "Done" "restart your shell to pick up new runtime versions"
}

action_install() {
  if [ -z "$PKG" ]; then
    err "no supported package manager found (brew/dnf/apt/pacman/zypper)"; exit 1
  fi
  platform_tested || warn "$OS_ID is untested — modules run best-effort via $PKG"

  header "Dotfiles bootstrap" "$DOTFILES" "$OS_ID · $PKG · profile ${PROFILE:-full}"
  dry && warn "dry run — nothing will be changed"

  # Offer gum up front so the rest of the run is fancy, but only when the package
  # manager can already see it: on a fresh Fedora it arrives with brew in the
  # packages module, so prompting here would be a guaranteed failure.
  if ! has gum && [ "${DOTFILES_YES:-0}" != "1" ] && ! dry && pkg_available gum; then
    if ask "Install 'gum' for a nicer installer UI?"; then pkg_install gum || true; fi
  fi

  local modules selected
  modules="$(runner_modules install)"
  selected="$(runner_select "$modules" "${FILTERS[*]:-}" "$ONLY" "$SKIP")"
  [ -z "$selected" ] && { warn "nothing selected"; exit 0; }

  runner_run "$modules" "$selected" || true

  printf '\n'
  if is_macos; then header "Done" "Restart your terminal (and iTerm2) to pick everything up."
  else header "Done" "Restart your terminal (or log out/in) to pick everything up."; fi
  dry || info "verify with:  ./install.sh --doctor"
}

case "$ACTION" in
  list)     action_list install ;;
  coverage) action_coverage ;;
  doctor)   action_doctor ;;
  unlink)   action_unlink ;;
  upgrade)  action_upgrade ;;
  install)  action_install ;;
esac
