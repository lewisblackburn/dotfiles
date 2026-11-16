<div align="center">

# 🌿 dotfiles

**Ghostty · tmux · zsh · Starship · LazyVim**, all in Gruvbox Dark

macOS & Fedora · built with [Nix](https://nixos.org) · keys in [keymaps.md](keymaps.md)

</div>

## 🧰 The stack

| | |
|---|---|
| **Nix** | [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [Home Manager](https://github.com/nix-community/home-manager) install the tools and link every config |
| **Terminal** | [Ghostty](https://ghostty.org), frameless; [tmux](https://github.com/tmux/tmux) draws the tabs, driven by `cmd` keys |
| **Shell** | zsh with autosuggestions, highlighting and a collapsing [Starship](https://starship.rs) prompt; [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf), [sesh](https://github.com/joshmedeski/sesh) |
| **Editor** | [LazyVim](https://lazyvim.org) for Java and web, with debugger, tests and a DB UI |
| **Runtimes** | [mise](https://mise.jdx.dev): Java 21 / 17 / 25, Node 24, pnpm, Python |
| **Apps** | Homebrew casks on the Mac (via nix-darwin); dnf on Fedora |

## 📁 Layout

```
flake.nix       Mac + Fedora setups, Mac apps
home.nix        tools and config links
zsh/  ghostty/  tmux/  nvim/  git/  mise/  starship.toml
```

Configs link straight to this folder, so edits are live. Secrets stay out: `~/.config/zsh/.env` (see `zsh/.env.example`) and `~/.config/git/local.gitconfig` for the email.

## 🍎 New Mac

```sh
xcode-select --install
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:lewisblackburn/dotfiles.git ~/dotfiles
sudo nix run nix-darwin -- switch --flake ~/dotfiles#mac
```

## 🎩 New Fedora

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

> Usernames live in `flake.nix` (`lewis.blackburn` on Mac, `lewis` on Fedora). Change them first if yours differ.

## ✅ Then, on both

```sh
curl -fsSL https://claude.ai/install.sh | bash   # Claude Code
mise install                                     # runtimes
```

Fill in `~/.config/zsh/.env` and `~/.config/git/local.gitconfig`. Neovim installs its plugins on first start.

## 🔁 Day to day

| Changed | Run |
|---|---|
| `flake.nix` / `home.nix` | `sudo darwin-rebuild switch --flake ~/dotfiles#mac` (Fedora: `home-manager switch --flake ~/dotfiles#fedora`) |
| `mise/config.toml` | `mise install` |
| Update everything | `nix flake update --flake ~/dotfiles`, then rebuild |
| Anything | `git add -A && git commit -m "..." && git push` |
