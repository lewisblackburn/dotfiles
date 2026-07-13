# dotfiles

My macOS dev environment — AstroNvim, terminal, shell, and everything around them.
One command sets up a fresh machine; a `git pull` keeps existing ones current.

## First push (once, from the machine that has this repo)

```bash
cd ~/dotfiles
gh repo create lewisblackburn/dotfiles --private --source=. --remote=origin --push
# or manually:
# git remote add origin git@github.com:lewisblackburn/dotfiles.git && git push -u origin main
```

## New machine

```bash
git clone https://github.com/lewisblackburn/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` walks through each tool and asks before running it (Enter = yes).
It installs Homebrew + everything in the `Brewfile`, then **creates all the
symlinks for you** — you never link anything by hand.

```bash
./install.sh --yes      # non-interactive, run everything
./install.sh 06         # run just the neovim module (matches by number/name)
```

## How it works — symlinks, not copies

Your live config paths are symlinks into this repo:

| Live path | → | Repo |
|-----------|---|------|
| `~/.config/nvim` | → | `config/nvim` |
| `~/.zshrc`, `~/.zprofile` | → | `config/zsh/` |
| `~/.gitconfig` | → | `config/git/.gitconfig` |
| `~/.config/starship.toml` | → | `config/starship/` |
| `~/.config/lazygit/config.yml` | → | `config/lazygit/` |
| `~/.config/espanso` | → | `config/espanso` |
| `~/.config/gh/config.yml` | → | `config/gh/config.yml` |

So **editing a config edits the repo directly** — there's no copy/sync step.

When `install.sh` (or the `link` helper) finds a *real* file where a symlink
should go, it moves the original to `~/…​.bak.<timestamp>` first. Once you've
confirmed everything works, those `*.bak` files are safe to delete.

## Everyday use

- **Changed a config?** It's already in the repo (it's a symlink). Push it:
  ```bash
  dot push "tweak nvim keymaps"     # add + commit + push
  ```
- **Update another machine?** Just pull — symlinks make it instantly live:
  ```bash
  dot pull
  ```
- **Added a new tool?** Re-run `./install.sh` (or `dot install`). Idempotent:
  it skips what's already there and only sets up what's new.

`dot` lives in `bin/` — add it to PATH: `export PATH="$HOME/dotfiles/bin:$PATH"`
(`dot status | push | pull | edit | iterm-export | install`).

## Idempotency

Re-running `install.sh` **converges** the machine to match the repo:
- installed tools are skipped (no reinstall);
- correct symlinks are left alone; a real file in the way is backed up to `*.bak`;
- it never resets or overwrites your tweaks.

It provisions structure. **Config *content* updates come from `git pull`**, not
from re-running the installer.

## What's covered

`Brewfile` — every formula, cask, font, and VS Code extension.
`install/` — one module per tool:

| Module | Sets up |
|--------|---------|
| `01-homebrew` | Homebrew + `brew bundle` |
| `02-zsh` | oh-my-zsh, plugins, `.zshrc`/`.zprofile`, default shell |
| `03-starship` | prompt config |
| `04-node` | nvm + Node 20 + pnpm |
| `05-java` | verifies Temurin 17 + 21 (jdtls uses both) |
| `06-neovim` | links AstroNvim config + bootstraps plugins/parsers |
| `07-tmux` | tmux (also backs sidekick.nvim's Claude sessions) |
| `08-git` | global gitconfig |
| `09-cli-tools` | lazygit, gh |
| `10-terminal` | iTerm2 prefs (import) |
| `11-extras` | espanso, aerospace, karabiner, android tools |

## Not in the repo (per-machine)

- **gh auth token** — run `gh auth login`.
- **iTerm2 prefs** — a plist, so imported not symlinked. Re-export after changes
  with `dot iterm-export`, then `dot push`.
