#!/usr/bin/env bash
# Reader for packages/tools.csv — the one tool list every platform shares.
#
# Sourced after lib/common.sh (it needs $DOTFILES, $OS_ID and the log helpers).
#
# The CSV columns are:  id,category,macos,fedora,windows_host,notes
# and each platform cell is "source:name" (see the header of the CSV itself).
#
# Two knobs, both set by install.sh from its flags:
#   PROFILE          full | cli | minimal      (default: full)
#   REGISTRY_NO_GUI  1 to drop gui/font/vscode (implied by --no-gui)

REGISTRY_CSV="$DOTFILES/packages/tools.csv"

# Which CSV column holds this machine's entries.
#   3 = macos, 4 = fedora (and any other Linux — brew names are identical),
#   5 = windows_host (only ever selected explicitly, by the Windows scripts).
registry_column() {
  if [ -n "${REGISTRY_COLUMN:-}" ]; then printf '%s\n' "$REGISTRY_COLUMN"; return; fi
  if is_macos; then printf '3\n'; else printf '4\n'; fi
}

# Every data row: no comments, no blank lines, no header.
registry_rows() {
  grep -vE '^[[:space:]]*(#|$)' "$REGISTRY_CSV" | tail -n +2
}

# The categories enabled by the current profile, one per line.
# full     everything
# cli      no GUI apps, fonts or VS Code extensions — the WSL/headless case
# minimal  cli + runtimes only: enough to work, nothing else
registry_categories() {
  local profile="${PROFILE:-full}"
  case "$profile" in
    minimal) printf '%s\n' cli runtime ;;
    cli)     printf '%s\n' cli runtime npm ;;
    full)
      if [ "${REGISTRY_NO_GUI:-0}" = "1" ]; then printf '%s\n' cli runtime npm
      else printf '%s\n' cli runtime npm gui font vscode; fi ;;
    *) err "unknown profile '$profile' (want: full | cli | minimal)"; return 1 ;;
  esac
}

registry_category_enabled() {
  registry_categories | grep -qxF "$1"
}

# registry_entries <source> [column]
# Prints the bare names for every enabled row whose cell for this platform uses
# <source>. e.g. `registry_entries brew` -> ripgrep, gum, fzf, ...
registry_entries() {
  local want="$1" col="${2:-$(registry_column)}" row cat cell
  while IFS= read -r row; do
    cat="$(printf '%s' "$row" | cut -d, -f2)"
    registry_category_enabled "$cat" || continue
    cell="$(printf '%s' "$row" | cut -d, -f"$col")"
    case "$cell" in
      "$want":*) printf '%s\n' "${cell#*:}" ;;
    esac
  done < <(registry_rows)
}

# registry_note <id> -> the notes column, for error messages.
registry_note() {
  registry_rows | awk -F, -v id="$1" '$1 == id { print $6 }'
}

# Taps implied by cask names of the form "owner/tap/cask".
registry_taps() {
  local name
  while IFS= read -r name; do
    case "$name" in */*/*) printf '%s/%s\n' "${name%%/*}" "$(printf '%s' "$name" | cut -d/ -f2)" ;; esac
  done < <(registry_entries cask) | sort -u
}

# registry_brewfile <outfile>
# Renders a Brewfile for this platform and profile. Only brew/cask/vscode go in
# it: mise runtimes and npm globals are installed by install/shared/20-runtimes.sh
# (brew bundle would run npm entries before node exists), and nerdfont/dnf rows
# belong to their own modules.
registry_brewfile() {
  local out="$1" name
  : > "$out"
  registry_taps | sed 's/^/tap "/; s/$/"/' >> "$out"
  registry_entries brew | sed 's/^/brew "/; s/$/"/' >> "$out"
  registry_entries cask | sed 's/^/cask "/; s/$/"/' >> "$out"
  # VS Code extensions only make sense when VS Code is actually installed.
  if has code; then
    registry_entries vscode | sed 's/^/vscode "/; s/$/"/' >> "$out"
  fi
  grep -c . "$out" || true
}

# registry_gaps
# Rows available on one of the two full environments but not the other. This is
# the "all platforms should have the same tools" check — it makes divergence
# visible rather than something you discover on a fresh machine.
# The windows_host column is not compared: Windows runs as WSL2, so its tools
# come from the Fedora column and only fonts/terminal live on the host.
registry_gaps() {
  registry_rows | awk -F, '
    $3 == "" && $4 == "" { next }                       # in neither: not a gap
    $3 == "" { printf "%-28s %-8s missing on macOS   %s\n", $1, $2, $6 }
    $4 == "" { printf "%-28s %-8s missing on Fedora  %s\n", $1, $2, $6 }
  '
}

# brew_apply_registry
# Render this platform's Brewfile from the registry and hand it to brew bundle.
# Replaces the old hand-maintained Brewfile plus its BREW_SKIP_LINUX filtering:
# what a platform gets is now just "the rows with a cell in that column".
brew_apply_registry() {
  local bf n
  bf="$(mktemp)"
  trap 'rm -f "$bf"' RETURN
  registry_brewfile "$bf" >/dev/null
  n="$(grep -c . "$bf" || true)"

  log "brew bundle — $n entries (safe to re-run)"
  info "runtimes come from mise and npm globals from 20-runtimes — not brew"
  has code || info "no 'code' on PATH — VS Code extensions skipped"

  if dry; then sed 's/^/      /' "$bf"; return 0; fi

  # brew bundle continues past individual failures and exits non-zero at the
  # end, so one unavailable formula shouldn't abort the whole install.
  brew bundle --file="$bf" && ok "packages applied" \
    || warn "some entries failed (see above) — the rest were installed"
}
