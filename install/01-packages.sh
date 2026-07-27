#!/usr/bin/env bash
# Package manager + every package for this OS (Brewfile on macOS, packages/ elsewhere).
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Packages (${PKG:-none})"

# ---------------------------------------------------------------- macOS ----
install_macos() {
  if ! has brew; then
    info "installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # make brew available in this shell (Apple Silicon path)
    if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  else
    ok "Homebrew present"
  fi

  log "brew bundle (installs/updates everything in Brewfile — safe to re-run)"
  brew bundle --file="$DOTFILES/Brewfile"
  ok "Brewfile applied"
}

# ---------------------------------------------------------------- Linux ----
# Extra repos for tools the distro doesn't ship itself.
fedora_repos() {
  if [ ! -f /etc/yum.repos.d/charm.repo ]; then
    info "adding Charm repo (gum)..."
    $SUDO tee /etc/yum.repos.d/charm.repo >/dev/null <<'EOF'
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
EOF
  fi
}

# Tools with no distro package: fall back to their official installers.
# All best-effort — a failure warns, it doesn't stop the run.
linux_fallbacks() {
  # gum comes from the Charm repo added above.
  if ! has gum; then
    pkg_install gum >/dev/null 2>&1 && ok "gum installed (fancy installer UI)" \
      || warn "gum unavailable (installer UI stays plain — cosmetic only)"
  fi

  if ! has starship; then
    info "installing starship (official installer -> ~/.local/bin)..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://starship.rs/install.sh \
      | sh -s -- --yes --bin-dir "$HOME/.local/bin" >/dev/null 2>&1 \
      && ok "starship installed" || warn "starship install failed"
  fi

  if ! has deno && ask "Install deno (official installer)?" N; then
    curl -fsSL https://deno.land/install.sh | sh -s -- -y >/dev/null 2>&1 \
      && ok "deno installed (~/.deno/bin)" || warn "deno install failed"
  fi

  # Nerd Fonts: no distro packages exist for the patched variants, so pull the
  # same two the Brewfile installs as casks on macOS. Only fetches what's
  # missing, so a part-finished run resumes cleanly.
  local fontdir="$HOME/.local/share/fonts/NerdFonts"
  local base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
  local tmp="${TMPDIR:-/tmp}" f
  local -a need=()
  for f in FiraCode Hack; do
    compgen -G "$fontdir/$f*" >/dev/null || need+=("$f")
  done
  if [ "${#need[@]}" -gt 0 ] && ask "Download Nerd Fonts (${need[*]})?"; then
    mkdir -p "$fontdir"
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
    has fc-cache && fc-cache -f "$fontdir" >/dev/null 2>&1 && ok "font cache rebuilt"
  elif [ "${#need[@]}" -eq 0 ]; then
    ok "nerd fonts present"
  fi

  # Kotlin tooling: only `kotlin` itself is (sometimes) packaged.
  local t
  for t in kotlin-language-server ktlint ktfmt; do
    has "$t" || info "$t not packaged for $OS_ID — install manually if you need it"
  done
}

install_linux() {
  is_fedora && fedora_repos
  pkg_sync
  local manifest
  if manifest="$(pkg_manifest)"; then
    pkg_install_manifest "$manifest"
  else
    err "no packages/$OS_ID.txt (or packages/linux.txt) — copy packages/fedora.txt and adjust names"
    return 1
  fi
  linux_fallbacks
}

# ---------------------------------------------------------------------------
if is_macos; then
  install_macos
elif is_linux; then
  platform_tested || warn "$OS_ID isn't a tested distro — trying $PKG anyway"
  install_linux
else
  err "unsupported platform: $OS_FAMILY"; exit 1
fi
