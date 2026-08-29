#!/usr/bin/env bash
# The single source of truth for every symlink this repo owns.
#
# install/shared/40-links.sh creates them, `install.sh --doctor` verifies them,
# and `install.sh --unlink` removes them. Keeping the list in one place is what
# stops those three drifting apart.
#
# Format: "<path under config/>|<absolute target>". A source that doesn't exist
# in the repo is skipped silently — that's how optional configs (ssh, tmux)
# stay optional without needing a conditional at every call site.

dotfiles_links() {
  cat <<'LINKS'
zsh/.zshrc|HOME/.zshrc
zsh/.zprofile|HOME/.zprofile
git/.gitconfig|HOME/.gitconfig
git/.gitignore_global|HOME/.config/git/ignore
nvim|HOME/.config/nvim
mise/config.toml|HOME/.config/mise/config.toml
starship/starship.toml|HOME/.config/starship.toml
lazygit/config.yml|HOME/.config/lazygit/config.yml
gh/config.yml|HOME/.config/gh/config.yml
tmux/tmux.conf|HOME/.config/tmux/tmux.conf
tinted-theming/tinty/config.toml|HOME/.config/tinted-theming/tinty/config.toml
espanso|HOME/.config/espanso
ssh/config|HOME/.ssh/config
ghostty/themes|HOME/.config/ghostty/themes
LINKS

  if is_macos; then
    printf '%s\n' 'ghostty/config|HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty'
  else
    printf '%s\n' 'ghostty/config|HOME/.config/ghostty/config'
  fi
}

# links_each <callback>
# Calls <callback> "<src>" "<dst>" for every link whose source exists.
links_each() {
  local fn="$1" src dst
  while IFS='|' read -r src dst; do
    [ -n "$src" ] || continue
    src="$CONFIG_DIR/$src"
    dst="${dst/#HOME/$HOME}"
    [ -e "$src" ] || continue
    "$fn" "$src" "$dst"
  done < <(dotfiles_links)
}
