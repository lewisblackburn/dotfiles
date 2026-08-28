# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# node used to come from nvm here. mise owns it now (see the activate line
# below) — running both put two different node versions on PATH.
command -v starship >/dev/null && eval "$(starship init zsh)"

alias lazygit='lazygit --use-config-file ~/.config/lazygit/config.yml'

export PATH="$HOME/.local/bin:$PATH"

# pnpm (macOS keeps its store under ~/Library, Linux follows XDG)
if [[ "$(uname -s)" == "Darwin" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# dotfiles helper (dot push/pull/status/...). Derived from where ~/.zshrc
# actually points, so a repo cloned somewhere other than ~/dotfiles still works.
DOTFILES_DIR="${${(%):-%N}:A:h:h:h}"
[[ -d "$DOTFILES_DIR/bin" ]] || DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_DIR
export PATH="$DOTFILES_DIR/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Point Docker-aware tools (e.g. docker-maven-plugin) at the Rancher Desktop
# daemon socket — only when Rancher is actually installed (macOS). On Linux the
# native /var/run/docker.sock default is correct, so leave DOCKER_HOST unset.
[[ -S "$HOME/.rd/docker.sock" ]] && export DOCKER_HOST="unix://$HOME/.rd/docker.sock"

# Rancher Desktop's own installer writes an absolute path here; $HOME keeps it
# working on a second machine or a different user.
[[ -d "$HOME/.rd/bin" ]] && export PATH="$HOME/.rd/bin:$PATH"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

# zoxide: smarter `cd`. Supersedes the oh-my-zsh `z` plugin, which is still in
# the plugins list above for its completions — zoxide's `z` wins because this
# runs after oh-my-zsh has loaded.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# fzf: ctrl-r history search and ctrl-t file search.
command -v fzf >/dev/null && source <(fzf --zsh) 2>/dev/null

# Secrets / machine-local env (Jira PAT etc) — untracked, see .gitignore
[ -f "$DOTFILES_DIR/config/zsh/.env" ] && source "$DOTFILES_DIR/config/zsh/.env"

# Java (and every other runtime) comes from mise: it exports JAVA_HOME and puts
# the active versions on PATH. The global pins live in config/mise/config.toml
# (linked to ~/.config/mise/); pin one project with `mise use java@temurin-21`,
# which writes a local .mise.toml.
#
# Activated LAST on purpose. Everything above that prepends to PATH — bun,
# ~/.rd/bin, ~/.local/bin — would otherwise sit in front of mise's shims and
# shadow the pinned versions with whatever brew happens to have installed.
command -v mise >/dev/null && eval "$(mise activate zsh)"
