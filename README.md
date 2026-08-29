# dotfiles

My shell, terminal, AstroNvim, and development tools.

Supported: macOS, Fedora, and WSL2. The installer is safe to re-run; configs
are symlinked into place rather than copied.

## Install

### macOS / Fedora

```sh
git clone --recurse-submodules https://github.com/lewisblackburn/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Windows

Run this from PowerShell after cloning the repository:

```powershell
.\install.ps1
```

It installs a Fedora WSL2 environment, then runs the normal installer inside
it.

## Everyday commands

```sh
dot install                 # interactive installer
dot install --yes           # install everything without prompts
dot upgrade                 # update packages, runtimes, plugins
dot outdated                # report available updates
dot doctor                  # check for drift
dot pull                    # pull dotfiles and update submodules
dot push "message"          # commit and push changes
```

Useful installer options:

```sh
./install.sh --only 50-neovim
./install.sh --dry-run --yes
./install.sh --profile cli
./install.sh --no-gui
./install.sh --coverage
```

`install` provisions missing tools and links. `upgrade` deliberately moves
versions forward. Run `dot outdated` before an upgrade when you want to see
what will change.

## How it is organised

```
config/       symlinked application configuration
install/      numbered install modules
lib/          installer, package-registry, and link helpers
packages/     one cross-platform tool registry
themes/       pinned public theme submodules
bin/dot       everyday command wrapper
```

`packages/tools.csv` is the source of truth for packages. It records the
installer and platform for each tool; `./install.sh --coverage` reports
platform gaps.

`config/` is the source of truth for live configuration. `40-links` creates
the links, `dot doctor` checks them, and `./install.sh --unlink` removes only
links owned by this repository. Existing files are backed up first.

## Theme

[VS Code Dark 2026](https://github.com/lewisblackburn/vscode-dark-2026) is a
pinned submodule used by Neovim and Ghostty. Clone with `--recurse-submodules`
or repair an existing checkout with:

```sh
git submodule update --init --recursive
```

Neovim and Ghostty use the direct theme ports for the closest VS Code match.
Tinty supplies the same Base24 palette to compatible tools; it currently
themes tmux. Reapply it with:

```sh
dot install --only 61-tinty-theme
```

## Notes

- Mise owns language runtimes. Its configuration is in
  `config/mise/config.toml`.
- `lazy-lock.json` pins Neovim plugin versions across machines.
- GitHub authentication is per-machine: run `gh auth login`.
- SSH keys are generated locally. Put machine-specific hosts in
  `~/.ssh/config.local`.
- `config/zsh/.env` is ignored by Git and intended for secrets.
- iTerm2 preferences are imported/exported rather than symlinked:
  `dot iterm-export`.

Static checks run in GitHub Actions: shellcheck, Bash syntax checks, CSV
validation, and PSScriptAnalyzer.
