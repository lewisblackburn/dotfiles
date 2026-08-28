#!/usr/bin/env bash
# Language runtimes via mise (java 17+21, node, pnpm, bun, go, deno, rust, python).
#
# mise replaces both nvm and the JDK casks/formulae: one tool, one config file
# (config/mise/config.toml), identical on macOS, Fedora and WSL. config/zsh/.zshrc
# activates it, which is what sets JAVA_HOME and puts the runtimes on PATH.
set -euo pipefail
DOTFILES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib"
source "$DOTFILES_LIB/common.sh"
source "$DOTFILES_LIB/registry.sh"
source "$DOTFILES_LIB/links.sh"

log "Runtimes (mise)"

# ---- mise itself ----------------------------------------------------------
# Normally already present: it's a `brew:mise` row in the registry, so the
# packages module installed it. The official installer is the fallback for a
# machine where brew failed or isn't wanted.
if ! has mise; then
  warn "mise not on PATH — installing via the official script"
  run_sh 'curl -fsSL https://mise.run | sh'
  export PATH="$HOME/.local/bin:$PATH"
fi
if ! has mise; then
  if dry; then info "would continue once mise is installed"; exit 0; fi
  err "mise still not found — install it and re-run: ./install.sh --only 20-runtimes"
  exit 1
fi
ok "mise $(mise --version | awk '{print $1}')"

# ---- the global config ----------------------------------------------------
# Linked here as well as in 40-links so that running this module on its own
# still works; link() is idempotent, so doing it twice costs nothing.
link "$CONFIG_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"

# ---- install the pinned runtimes ------------------------------------------
# Read from the registry rather than hardcoded, so tools.csv stays the one list.
runtimes=()
while IFS= read -r r; do [ -n "$r" ] && runtimes+=("$r"); done < <(registry_entries mise)

if [ "${#runtimes[@]}" -eq 0 ]; then
  info "no runtime rows enabled for this profile — skipping"
else
  info "pinned: ${runtimes[*]}"
  # `mise install` with no args honours the config file; that's the one that
  # matters. Naming them explicitly would drift from config.toml.
  spin "installing runtimes (first run downloads several JDKs)..." -- mise install \
    && ok "runtimes installed" \
    || warn "some runtimes failed — check with: mise ls"
  dry || mise ls --current 2>/dev/null | sed 's/^/      /' || true
fi

# ---- global npm packages --------------------------------------------------
# These run here, after mise's node exists, rather than under `brew bundle`:
# brew installs npm entries before the node formula, so on a fresh machine they
# either fail outright or write into a root-owned global prefix.
npm_pkgs=()
while IFS= read -r p; do [ -n "$p" ] && npm_pkgs+=("$p"); done < <(registry_entries npm)

if [ "${#npm_pkgs[@]}" -gt 0 ]; then
  log "npm globals"
  if ! dry && ! mise exec -- node --version >/dev/null 2>&1; then
    warn "mise has no usable node yet — skipping npm globals"
  else
    for pkg in "${npm_pkgs[@]}"; do
      if ! dry && mise exec -- npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
        ok "$pkg present"; continue
      fi
      spin "installing $pkg..." -- mise exec -- npm install -g "$pkg" \
        && ok "$pkg installed" \
        || warn "$pkg failed (private registry? may need 'npm login')"
    done
  fi
fi

# ---- leftovers from before mise owned runtimes -----------------------------
# `brew bundle` never uninstalls, so formulae dropped from the registry stay
# behind. Interactive shells are fine (mise activates last in .zshrc, so its
# shims win) but a non-interactive shell falls through to brew's copy, which is
# a different version.
#
# Split into two lists, because they need different answers: a formula nothing
# depends on is just cruft, while one that something else pins can't be removed
# without taking that tool with it. `brew uninstall` would refuse the second
# kind anyway — better to say so than to suggest a command that fails.
log "Runtime leftovers"
removable=(); pinned=()
if has_brew; then
  for f in node pnpm go deno rust python@3.12 python@3.13 python@3.14; do
    brew list --versions "$f" >/dev/null 2>&1 || continue
    deps="$(brew uses --installed --recursive "$f" 2>/dev/null | tr '\n' ' ')"
    if [ -n "${deps// /}" ]; then pinned+=("$f (needed by ${deps% })"); else removable+=("$f"); fi
  done
  # The JDKs are the usual pinned case: maven, gradle, kotlin and ktlint all
  # declare a brew openjdk dependency. They're keg-only, so they never shadow
  # mise on PATH — leaving them costs nothing but disk.
  for f in openjdk openjdk@17 openjdk@21; do
    brew list --versions "$f" >/dev/null 2>&1 || continue
    deps="$(brew uses --installed --recursive "$f" 2>/dev/null | tr '\n' ' ')"
    if [ -n "${deps// /}" ]; then pinned+=("$f (needed by ${deps% })"); else removable+=("$f"); fi
  done
  # Temurin casks predate mise owning Java. jdtls asks mise first, so these only
  # still matter to /usr/libexec/java_home.
  for c in temurin temurin@17 temurin@21; do
    brew list --cask "$c" >/dev/null 2>&1 && removable+=("cask $c")
  done
fi
[ -d "$HOME/.nvm" ] && removable+=("nvm at $HOME/.nvm")

if [ "${#removable[@]}" -eq 0 ] && [ "${#pinned[@]}" -eq 0 ]; then
  ok "nothing installed outside mise duplicates a managed runtime"
else
  if [ "${#removable[@]}" -gt 0 ]; then
    warn "superseded by mise and safe to remove: ${removable[*]}"
    info "  brew uninstall <formula>   /   brew uninstall --cask <cask>   /   rm -rf ~/.nvm"
    info "  then: brew autoremove"
    info "left in place on purpose — removing something you still depend on is worse"
  fi
  if [ "${#pinned[@]}" -gt 0 ]; then
    for p in "${pinned[@]}"; do info "kept (another formula depends on it): $p"; done
    info "these are keg-only, so they don't shadow mise on PATH"
  fi
fi

info "shells pick this up via 'mise activate zsh' in .zshrc — restart your shell"
