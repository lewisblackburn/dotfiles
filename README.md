# dotfiles

Ghostty, tmux, zsh, Starship and LazyVim in Gruvbox, set up with Nix. Keys are in [keymaps.md](keymaps.md).

## New Mac

```sh
xcode-select --install
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:lewisblackburn/dotfiles.git ~/dotfiles
sudo nix run nix-darwin -- switch --flake ~/dotfiles#mac
```

The username is set in `flake.nix` (`lewis.blackburn`). Change it first if this Mac's user is different.

Chrome isn't in the list because work IT manages it; on a personal Mac, download it from google.com/chrome.

## New Fedora

```sh
sudo dnf install zsh gcc moby-engine docker-compose
sudo dnf copr enable scottames/ghostty && sudo dnf install ghostty
sudo dnf install fedora-workstation-repositories
sudo dnf config-manager setopt google-chrome.enabled=1 && sudo dnf install google-chrome-stable
chsh -s "$(which zsh)"
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
git clone git@github.com:lewisblackburn/dotfiles.git ~/dotfiles
nix run home-manager -- switch --flake ~/dotfiles#fedora
```

The username is set in `flake.nix` (`lewis`). Change it first if yours is different.

## Then, on both

```sh
curl -fsSL https://claude.ai/install.sh | bash   # Claude Code
mise install                                     # Java, Node, Python
```

Copy `zsh/.env.example` to `~/.config/zsh/.env` and fill it in, and put your git email in `~/.config/git/local.gitconfig`:

```ini
[user]
	email = you@example.com
```

Neovim installs its plugins on first start.

## Day to day

- Config files link straight into this folder, so edits apply at once. Reload: Ghostty `cmd+shift+,`, tmux `ctrl+space r`, zsh new tab, nvim restart.
- After editing `mise/config.toml`, run `mise install`.
- After changing `flake.nix` or `home.nix` (adding a package or app), rebuild:
  - Mac: `sudo darwin-rebuild switch --flake ~/dotfiles#mac`
  - Fedora: `home-manager switch --flake ~/dotfiles#fedora`
- Update everything: `nix flake update --flake ~/dotfiles`, then rebuild.
- Save changes: `git add -A && git commit -m "..." && git push`.
