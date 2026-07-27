#!/usr/bin/env bash
# zsh + oh-my-zsh + custom plugins, and link the shell dotfiles.
# platforms: all
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "zsh + oh-my-zsh"

# zsh itself comes from the package step, but bail early with a clear message
# rather than half-configuring a machine without it.
if ! has zsh; then err "zsh missing — run module 01 first"; exit 1; fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  ok "oh-my-zsh present"
fi

# custom plugins referenced in .zshrc: zsh-autosuggestions, zsh-syntax-highlighting
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local name="$1" url="$2" dir="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dir" ]; then ok "$name present"; else
    info "cloning $name..."; git clone --depth=1 "$url" "$dir"
  fi
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# link shell dotfiles
link "$CONFIG_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link "$CONFIG_DIR/zsh/.zprofile" "$HOME/.zprofile"

# default shell -> zsh
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  if ask "Set default shell to zsh?"; then
    zsh_path="$(command -v zsh)"
    grep -qxF "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$zsh_path" && ok "default shell set to zsh (restart terminal)"
  fi
else
  ok "default shell already zsh"
fi
