# dotfiles

My dev environment: AstroNvim, terminal, shell, and everything around them.
One command sets up a fresh machine; `dot upgrade` keeps existing ones current.

Supported: **macOS**, **Fedora**, and **Windows via WSL2**. One tool list
(`packages/tools.csv`) drives all three, so the same tools land everywhere they
can — and `./install.sh --coverage` tells you where they can't.

## New machine

**macOS / Fedora**

```bash
git clone --recurse-submodules https://github.com/lewisblackburn/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Windows** — run from PowerShell, in the repo:

```powershell
.\install.ps1
```

Windows is provisioned as WSL2: `install.ps1` installs WSL2 and a Fedora guest,
sets up the pieces that must live on the Windows *host* (Nerd Fonts, Windows
Terminal), then runs `./install.sh --no-gui` inside the guest. The host half
isn't optional decoration — WSL renders in a Windows terminal using Windows
fonts, so without it the prompt is a row of broken boxes.

`install.sh` shows an interactive multi-select menu (powered by
[`gum`](https://github.com/charmbracelet/gum)). Space toggles steps, Enter runs
them, everything preselected. Without `gum` it falls back to yes/no prompts, and
offers to install `gum` on the first run.

On Fedora the dnf system layer uses `sudo`, so expect a password prompt early.

## The installer

```bash
./install.sh                  # interactive menu
./install.sh --yes            # everything, no prompts
./install.sh 50 60            # just the modules matching "50" or "60"
./install.sh --dry-run --yes  # print everything it would do, change nothing
```

| Flag | What it does |
|------|--------------|
| `--only a,b` / `--skip a,b` | include / exclude modules by name or number |
| `--profile full\|cli\|minimal` | which tool categories to install |
| `--no-gui` | skip GUI apps, fonts and VS Code extensions (WSL, servers) |
| `--distro ID` | force a Linux distro profile instead of auto-detecting |
| `--list` | list the modules that apply to this machine |
| `--coverage` | tools available on one platform but not the other |
| `--doctor` | verify the machine matches the repo; exits non-zero on drift |
| `--upgrade` | move packages, runtimes and plugins forward |
| `--outdated` | report what `--upgrade` would change; changes nothing |
| `--unlink` | remove this repo's symlinks, restoring the `*.bak` backups |
| `-n/--dry-run`, `-v/--verbose`, `-y/--yes` | |

`dot` wraps the common ones: `dot install`, `dot upgrade`, `dot outdated`,
`dot doctor`, `dot coverage`, plus `push`, `pull`, `reset`, `status`, `edit`,
`iterm-export`. It lives in `bin/` and `.zshrc` puts it on `PATH`.

## Install vs upgrade

These are deliberately separate:

- **`./install.sh` provisions structure.** It converges the machine to match the
  repo: installs what's missing, leaves correct symlinks alone, never changes a
  version you already have. Safe to re-run at any time.
- **`./install.sh --upgrade` moves versions.** Package manager, mise runtimes,
  oh-my-zsh, nvim plugins, Mason tools, gh extensions — in that order, because
  Mason's LSP installs need node and java from mise.

Run `--outdated` first to see what would change. An upgrade rewrites the tracked
`config/nvim/lazy-lock.json`, so it offers to commit and push at the end — that
lockfile is what pins every other machine to the same plugin versions.

Config *content* updates come from `git pull` (`dot pull`), not from the
installer. Symlinks make a pull instantly live.

This repository includes the public
[`vscode-dark-2026`](https://github.com/lewisblackburn/vscode-dark-2026) theme
as a pinned Git submodule. `dot pull` updates it automatically. If you cloned
without `--recurse-submodules`, run this once before opening Neovim or Ghostty:

```bash
git submodule update --init --recursive
```

### Shared palette with Tinty

`tinty` is installed from the package registry and its configuration is tracked
in `config/tinted-theming/`. `dot install` links the VS Code Dark 2026 Base24
scheme, syncs Tinted templates, and applies it to tmux. Re-run just that step
with:

```bash
dot install --only 61-tinty-theme
```

Neovim and Ghostty deliberately use the direct theme port from the submodule:
they match VS Code more closely than a generic Base24 template can. Tinty is
the shared palette layer for compatible tools, not a replacement for them.

## How it works: symlinks, not copies

Your live config paths are symlinks into this repo, so **editing a config edits
the repo directly** — there's no copy or sync step. The full list lives in one
place, `lib/links.sh`, which `40-links` creates, `--doctor` verifies and
`--unlink` removes.

| Live path | → | Repo |
|-----------|---|------|
| `~/.zshrc`, `~/.zprofile` | → | `config/zsh/` |
| `~/.gitconfig` | → | `config/git/.gitconfig` |
| `~/.config/git/ignore` | → | `config/git/.gitignore_global` |
| `~/.config/nvim` | → | `config/nvim` |
| `~/.config/mise/config.toml` | → | `config/mise/config.toml` |
| `~/.config/starship.toml` | → | `config/starship/` |
| `~/.config/lazygit/config.yml` | → | `config/lazygit/` |
| `~/.config/tmux/tmux.conf` | → | `config/tmux/` |
| `~/.config/gh/config.yml` | → | `config/gh/config.yml` |
| `~/.config/espanso` | → | `config/espanso` |
| `~/.ssh/config` | → | `config/ssh/config` |

When the installer finds a *real* file where a symlink should go, it moves the
original to `<path>.bak.<timestamp>` first. Once you've confirmed everything
works those are safe to delete — `--unlink` restores the newest one.

iTerm2 is the exception: it stores prefs in a plist it rewrites on quit, so a
symlink would fight it. It's imported instead. Re-export with `dot iterm-export`.

## Layout

```
install.sh              unix entry point: flags, then delegate
install.ps1             Windows entry point: WSL2 bootstrap
lib/
  common.sh             logging, link(), package-manager wrappers, dry-run
  registry.sh           reads packages/tools.csv
  links.sh              the one list of symlinks this repo owns
  runner.sh             module discovery, selection, ordering
install/
  shared/               runs on macOS, Fedora and WSL alike
  macos/                brew, casks, iTerm2, macOS defaults
  linux/                distro layer, linuxbrew, fonts, desktop
    distros/fedora.sh   the dnf system layer
  windows/              PowerShell: WSL2, host fonts + terminal
packages/
  tools.csv             the tool registry — one list, all platforms
  fedora.txt            dnf bootstrap layer only
config/                 everything that gets symlinked
```

### Modules

Modules live in `install/shared/` plus `install/<platform>/` and are merged into
one run, ordered by the number in the filename. `./install.sh --list` prints the
set for the machine you're on.

| Band | Purpose |
|------|---------|
| `0x` | platform bootstrap (Xcode CLT, Homebrew, distro system layer) |
| `1x` | packages |
| `2x` | runtimes (mise) |
| `3x` | shell (oh-my-zsh, default shell) |
| `4x` | symlinks, ssh |
| `5x` | editor (AstroNvim bootstrap) |
| `6x` | CLI tool checks |
| `7x` | platform extras (macOS defaults, iTerm2, fonts, desktop) |
| `9x` | upgrade — never part of a normal install |

Adding a step is dropping a numbered `.sh` file into the right directory: the
runner discovers it, and its description is the comment on line 2.

## One tool list: `packages/tools.csv`

Each row is a tool; each platform cell is `source:name`, empty where the tool
isn't available there.

```csv
id,category,macos,fedora,windows_host,notes
ripgrep,cli,brew:ripgrep,brew:ripgrep,,
java-21,runtime,mise:java@temurin-21,mise:java@temurin-21,,jdtls runs on this
iterm2,gui,cask:iterm2,,,no tracked Linux terminal config yet
```

Sources: `brew`, `cask` (macOS only), `dnf`, `mise`, `npm`, `nerdfont`, `vscode`.

The platform modules render their own column into a temp Brewfile and run
`brew bundle` on it — which is why there's no hand-maintained `Brewfile` any
more, and no per-OS skip list. What a platform gets is just "the rows with a
cell in that column".

**Parity is checkable.** `./install.sh --coverage` lists every row present on
one of macOS/Fedora but not the other. Today that's exactly the macOS-only GUI
apps (iTerm2, AeroSpace, Karabiner, Docker Desktop, android tools, espanso),
each with a note saying why. Anything else appearing there is drift.

`windows_host` is deliberately sparse: Windows runs as WSL2, so its tools come
from the Fedora column. Only fonts, which have to be installed on the host for
the terminal to render them, have a value.

### Profiles

`--profile` selects which categories install:

| Profile | Categories |
|---------|-----------|
| `full` (default) | everything |
| `cli` | `cli`, `runtime`, `npm` — no GUI apps, fonts or VS Code extensions |
| `minimal` | `cli`, `runtime` |

`--no-gui` is `full` minus the GUI/font/vscode categories. It's what the Windows
script passes into the WSL guest, and what you'd want on a server.

## Runtimes: mise owns all of them

Java, node, pnpm, bun, go, deno, rust and python all come from
[mise](https://mise.jdx.dev), pinned in `config/mise/config.toml` and identical
on every platform. `.zshrc` runs `mise activate zsh`, which is what sets
`JAVA_HOME` and puts the active versions on `PATH`.

```toml
[tools]
java = ["temurin-17", "temurin-21"]   # jdtls runs on 21, compiles against 17
node = "20"
```

Pin a single project with `mise use java@temurin-21`, which writes a local
`.mise.toml` that overrides the global config.

Nothing else installs a runtime: no `nvm`, no `node`/`go`/`deno`/`python`
formulae, no Temurin casks. `config/nvim/lua/plugins/jdtls.lua` asks
`mise where java@temurin-21` first, falling back to `/usr/libexec/java_home`,
`/usr/lib/jvm` and finally `exepath java` only where mise isn't set up.

`.zprofile` puts mise's **shims** on `PATH` and `.zshrc` runs `mise activate`
last. Both are needed: activate only rewrites `PATH` at an interactive prompt,
so the shims are what let a GUI-launched nvim find `node` for its Node-based
Mason servers. `--doctor` checks that a non-interactive login shell resolves
them, because that failure is otherwise silent.

Brew's `openjdk` formulae stay installed: `maven`, `gradle`, `kotlin`, `ktlint`,
`ktfmt` and `kotlin-language-server` declare them as dependencies. They're
keg-only, so they never shadow mise on `PATH` — `20-runtimes` reports what's
genuinely removable separately from what another formula pins.

The one exception is Python: `packages/fedora.txt` installs the *system*
`python3` and `python3-neovim`, because nvim's Python provider has to be the
interpreter that package installs into. mise's python is for project work.

> If you're coming from the nvm setup, `~/.nvm` is no longer used and is safe to
> delete. `--doctor` reminds you if it's still there.

## Platforms

**One package list, three platforms.** Homebrew runs on Linux, so the registry's
`brew:` rows install on Fedora exactly as they do on macOS. dnf covers only what
brew shouldn't own — its own build prerequisites, the login shell, system python
for nvim's provider, fontconfig, and podman.

Fedora specifics:

- Nerd Fonts are casks, so on Linux `70-fonts` downloads the same two faces from
  the nerd-fonts release into `~/.local/share/fonts`.
- `espanso` has a Linux build but isn't packaged for Fedora; `71-desktop` links
  your config and prints the download link.
- podman replaces Docker Desktop, and `distros/fedora.sh` enables the rootless
  podman socket so Docker-API clients (testcontainers, docker-maven-plugin) work.

**Still macOS-only**, with no automatic substitute: iTerm2, AeroSpace,
Karabiner-Elements, Docker Desktop. `71-desktop` names the closest Linux
equivalents (i3/sway, keyd, podman).

**Adding another distro**: drop in `install/linux/distros/<id>.sh` and
`packages/<id>.txt`, using the `ID` from `/etc/os-release`. `00-distro` finds it
automatically, or `--distro <id>` forces it. `lib/common.sh` already wraps
apt/pacman/zypper, so nothing else needs to change — those paths just aren't
tested. `packages/linux.txt` is the generic fallback.

## Neovim

AstroNvim, symlinked whole from `config/nvim`. `50-neovim` runs the one-off
bootstrap: `Lazy! sync`, treesitter parsers, and `MasonToolsInstall` for the ~22
LSP servers and formatters the astrocommunity packs declare. That last one
matters — without it they install lazily on your first real launch instead.

`lazy-lock.json` is tracked, so every machine gets the same plugin versions.

## Not in the repo (per-machine)

- **gh auth token**: `gh auth login`.
- **SSH keys**: generated by `45-ssh`, never committed. Machine-specific hosts
  go in `~/.ssh/config.local`, which `config/ssh/config` includes.
- **Secrets**: `config/zsh/.env` is gitignored and sourced by `.zshrc`.
- **iTerm2 prefs**: a plist, so imported not symlinked.

## Checks

`.github/workflows/lint.yml` runs `shellcheck -x` over every shell script,
`bash -n` over all of them, a `tools.csv` well-formedness check, and
PSScriptAnalyzer over the PowerShell. The installer provisions real machines, so
a typo's failure mode is a half-configured box — static checks are the only
safety net that doesn't need a throwaway VM.
