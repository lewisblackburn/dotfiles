# dotfiles

My dev environment: AstroNvim, terminal, shell, and everything around them.
One command sets up a fresh machine; a `git pull` keeps existing ones current.

Supported: **macOS** and **Fedora**. Homebrew does the heavy lifting on both, so
the `Brewfile` is the one package list; on Linux, dnf adds a small system layer.
The installer detects the OS and skips modules that don't apply — see
[Platforms](#platforms).

## New machine

```bash
git clone https://github.com/lewisblackburn/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` shows an interactive multi-select menu (powered by
[`gum`](https://github.com/charmbracelet/gum)). Space toggles steps, Enter
runs them (everything preselected). It installs Homebrew + everything in the
`Brewfile`, then **creates all the symlinks for you**, so you never link
anything by hand. Without `gum` it falls back to plain yes/no prompts, and it
offers to install `gum` on first run.

```bash
./install.sh --yes      # non-interactive, run everything
./install.sh 06         # run just the neovim module (matches by number/name)
```

On Fedora, the dnf system layer uses `sudo`, so expect a password prompt early
on. `gum` arrives with the Brewfile, so the *first* run's menu is plain text and
later runs are fancy.

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

The `Brewfile` is the package list on **both** OSes — Homebrew runs on Linux
too. `packages/<distro>.txt` covers only the small system layer brew shouldn't
own. `install/`: one module per tool:

| Module | Sets up | Platforms |
|--------|---------|-----------|
| `01-packages` | `brew bundle`, + dnf system layer & Nerd Fonts on Linux | all |
| `02-zsh` | oh-my-zsh, plugins, `.zshrc`/`.zprofile`, default shell | all |
| `03-starship` | prompt config | all |
| `04-node` | nvm + Node 20 + pnpm | all |
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

**One package list, two OSes.** Homebrew is supported on Linux, so the Brewfile
is the source of truth for CLI tools everywhere — no second list of distro
package names to keep in sync, and tools Fedora doesn't ship at all (`gum`,
`starship`, `deno`, `bottom`, `dua-cli`, `tree-sitter`, and the Kotlin set —
`kotlin-language-server`, `ktlint`, `ktfmt`, `gradle`) come from brew. 29 of the
35 formulae have Linux bottles; the rest are JVM or script formulae that install
from an upstream archive, so nothing compiles from source.

On Linux `01-packages` filters the Brewfile: casks are dropped (macOS-only),
`vscode` entries are dropped unless `code` is on `PATH`, and `BREW_SKIP_LINUX`
in that module drops `docker`, `docker-compose`, `openjdk`, `openjdk@17`, `zsh`
and `python@3.14` — those need to come from the system so systemd, `chsh`,
jdtls' `/usr/lib/jvm` lookup and nvim's python provider all work.

`packages/fedora.txt` is therefore short: brew's build prerequisites, the login
shell, system python + `python3-neovim`, `fontconfig`, and optional `podman`.
Format is a plain list with `#` comments and a `?` prefix for *optional*
(unavailable ones warn instead of failing the run); required packages install as
one batch, retried individually — and a failure prints the package manager's own
reason, since a wrong name and a broken mirror need different fixes.

No JDK is installed on Linux by default (Fedora's `java-*-openjdk-devel` names
move between releases). `brew install openjdk@17` is bottled and works; module
`05-java`, `jdtls.lua` and `.zshrc` all check brew's prefix as well as
`/usr/lib/jvm`, so it gets picked up with no further config.

The Brewfile's `npm` entries are installed by module `04-node`, not by `brew
bundle` — brew processes npm packages *before* the node formula, so on a fresh
machine they'd fail with no node present, or write to a root-owned global prefix.

**Still macOS-only**, with no automatic substitute: iTerm2, AeroSpace,
Karabiner-Elements, Rancher Desktop, and the Temurin casks (distro OpenJDK is
used instead). Nerd Fonts are casks too, so on Linux `01-packages` downloads
Fira Code + Hack from the nerd-fonts release into `~/.local/share/fonts`.
`espanso` has a Linux build but isn't packaged for Fedora, so `11-extras` links
your config and prints the download link. That module also names the closest
equivalents for the rest (i3/sway, keyd, podman).

**Adding another distro** (Debian, Arch, ...): drop in `packages/<id>.txt` using
the `ID` from `/etc/os-release`. `lib/common.sh` already wraps apt/pacman/zypper,
so nothing else needs to change — those paths just aren't tested.

## Not in the repo (per-machine)

- **gh auth token**: run `gh auth login`.
- **iTerm2 prefs**: a plist, so imported not symlinked. Re-export after changes
  with `dot iterm-export`, then `dot push`. (macOS only.)
