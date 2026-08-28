#!/usr/bin/env bash
# Nerd Fonts — downloaded from the release archive, since casks are macOS-only.
#
# Same two faces the macOS casks install, so the terminal renders the starship
# prompt and nvim's devicons identically on both platforms.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"

log "Nerd Fonts"

fontdir="$HOME/.local/share/fonts/NerdFonts"
base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
tmp="${TMPDIR:-/tmp}"

fonts=()
while IFS= read -r f; do [ -n "$f" ] && fonts+=("$f"); done < <(registry_entries nerdfont)
if [ "${#fonts[@]}" -eq 0 ]; then info "no font rows enabled for this profile"; exit 0; fi

# Only fetch what's missing, so a part-finished run resumes cleanly.
need=()
for f in "${fonts[@]}"; do
  compgen -G "$fontdir/$f*" >/dev/null || need+=("$f")
done
if [ "${#need[@]}" -eq 0 ]; then ok "nerd fonts present (${fonts[*]})"; exit 0; fi

ask "Download Nerd Fonts (${need[*]})?" || { info "skipped"; exit 0; }

run mkdir -p "$fontdir"
for f in "${need[@]}"; do
  if spin "fetching $f Nerd Font..." -- bash -c \
      "curl -fsSL '$base/$f.zip' -o '$tmp/$f.zip' \
       && unzip -oq '$tmp/$f.zip' -d '$fontdir' \
       && rm -f '$tmp/$f.zip'"; then
    ok "$f Nerd Font -> $fontdir"
  else
    warn "$f Nerd Font download failed"
  fi
done
has fc-cache && run_sh "fc-cache -f '$fontdir' >/dev/null 2>&1" && ok "font cache rebuilt"
exit 0
