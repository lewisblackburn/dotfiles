# dotfiles

My dev environment: AstroNvim, terminal, shell, and everything around them.
One command sets up a fresh machine; a `git pull` keeps existing ones current.

Supported: **macOS** (Homebrew) and **Fedora** (dnf). The installer detects the
OS and picks the right package source and modules — see
[Platforms](#platforms).

## New machine

```bash
git clone https://github.com/lewisblackburn/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` shows an interactive multi-select menu (powered by
[`gum`](https://github.com/charmbracelet/gum)). Space toggles steps, Enter
runs them (everything preselected). It installs every package for this OS
(`Brewfile` on macOS, `packages/fedora.txt` on Fedora), then **creates all the
symlinks for you**, so you never link anything by hand. Without `gum` it falls
back to plain yes/no prompts, and it offers to install `gum` on first run.

```bash
./install.sh --yes      # non-interactive, run everything
./install.sh 06         # run just the neovim module (matches by number/name)
```

On Fedora, `dnf` steps use `sudo`, so expect a password prompt early on.

## How it works: symlinks, not copies

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

So **editing a config edits the repo directly**. There's no copy/sync step.

When `install.sh` (or the `link` helper) finds a *real* file where a symlink
should go, it moves the original to `<path>.bak.<timestamp>` first. Once you've
confirmed everything works, those `*.bak` files are safe to delete.

## Everyday use

- **Changed a config?** It's already in the repo (it's a symlink). Push it:
  ```bash
  dot push "tweak nvim keymaps"     # add + commit + push
  ```
- **Update another machine?** Just pull. Symlinks make it instantly live:
  ```bash
  dot pull
  ```
- **Added a new tool?** Re-run `./install.sh` (or `dot install`). Idempotent:
  it skips what's already there and only sets up what's new.

`dot` lives in `bin/`. Add it to PATH: `export PATH="$HOME/dotfiles/bin:$PATH"`
(`dot status | push | pull | edit | iterm-export | install`).

## Idempotency

Re-running `install.sh` **converges** the machine to match the repo:
- installed tools are skipped (no reinstall);
- correct symlinks are left alone; a real file in the way is backed up to `*.bak`;
- it never resets or overwrites your tweaks.

It provisions structure. **Config *content* updates come from `git pull`**, not
from re-running the installer.

## What's covered

Package lists: `Brewfile` (macOS — formulae, casks, fonts, VS Code extensions)
and `packages/<distro>.txt` (Linux). `install/`: one module per tool:

| Module | Sets up | Platforms |
|--------|---------|-----------|
| `01-packages` | Homebrew + `brew bundle`, or dnf + `packages/fedora.txt` | all |
| `02-zsh` | oh-my-zsh, plugins, `.zshrc`/`.zprofile`, default shell | all |
| `03-starship` | prompt config | all |
| `04-node` | nvm + Node 20 + pnpm (+ npm LSPs on Linux) | all |
| `05-java` | verifies JDK 17 + 21 (jdtls uses both) | all |
| `06-neovim` | links AstroNvim config + bootstraps plugins/parsers | all |
| `07-tmux` | tmux | all |
| `08-git` | global gitconfig | all |
| `09-cli-tools` | lazygit, gh | all |
| `10-terminal` | iTerm2 prefs (import) | macOS |
| `11-extras` | espanso, plus per-OS WM / input tools | all |

## Platforms

Each module declares a `# platforms:` header (`all`, `macos`, `linux`, or a
distro id). Modules that don't apply are listed as skipped and never run, so
`./install.sh` is safe to run as-is on either OS.

**Fedora specifics**

- Packages come from `packages/fedora.txt`: plain list, `#` comments, and a `?`
  prefix for *optional* (if the repos don't have it you get a warning, not a
  failed run). Required packages install in one batch, retried individually if
  that batch fails.
- Not in the Fedora repos, so `01-packages` falls back to official installers:
  `gum` (Charm repo), `starship` (`~/.local/bin`), `deno` (opt-in), Nerd Fonts
  (downloaded into `~/.local/share/fonts`).
- **Not available on Linux at all** — these are macOS-only tools with no
  automatic substitute: iTerm2, AeroSpace, Karabiner-Elements, Rancher Desktop,
  Temurin casks (distro OpenJDK is used instead), and the Kotlin extras
  (`kotlin-language-server`, `ktlint`, `ktfmt`, and often `gradle`), which have
  no RPM and need manual installs. `espanso` has a Linux build but isn't
  packaged for Fedora, so the module links your config and prints the download
  link. Module `11-extras` names the closest equivalents (i3/sway, keyd).

**Adding another distro** (Debian, Arch, ...): drop in `packages/<id>.txt` using
the `ID` from `/etc/os-release`. `lib/common.sh` already wraps apt/pacman/zypper,
so nothing else needs to change — those paths just aren't tested.

## Not in the repo (per-machine)

- **gh auth token**: run `gh auth login`.
- **iTerm2 prefs**: a plist, so imported not symlinked. Re-export after changes
  with `dot iterm-export`, then `dot push`. (macOS only.)
