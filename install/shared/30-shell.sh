#!/usr/bin/env bash
# zsh: oh-my-zsh, the custom plugins .zshrc expects, and the default shell.
#
# The shell dotfiles themselves are linked by 40-links, not here — this module
# owns the software, that one owns the symlinks.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "zsh + oh-my-zsh"

if ! has zsh; then err "zsh missing — run the packages module first"; exit 1; fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "installing oh-my-zsh..."
  run_sh 'RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
else
  ok "oh-my-zsh present"
fi

# Custom plugins referenced by config/zsh/.zshrc's `plugins=(...)` line.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local name="$1" url="$2" dir="$ZSH_CUSTOM/plugins/$1"
  if [ -d "$dir" ]; then ok "$name present"
  else info "cloning $name..."; run git clone --depth=1 "$url" "$dir"; fi
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# Default shell -> zsh. Uses $SUDO rather than a bare `sudo` so this still works
# as root (a container, or a freshly created WSL distro).
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  if ask "Set default shell to zsh?"; then
    zsh_path="$(command -v zsh)"
    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
      run_sh "echo '$zsh_path' | $SUDO tee -a /etc/shells >/dev/null"
    fi
    run chsh -s "$zsh_path" && ok "default shell set to zsh (restart terminal)" \
      || warn "chsh failed — set it by hand: chsh -s $zsh_path"
  fi
else
  ok "default shell already zsh"
fi
