#!/usr/bin/env fish
set fish_greeting

# alias
alias l='ls -lvh'
alias h='history'
alias tailf='tail -f'
alias b='brew'
alias :q='exit'
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup; brew doctor'
alias l='ls -h'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias rm='trash'

# Fundle init
if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end
fundle plugin 'dracula/fish'
fundle plugin 'jhillyerd/plugin-git'
fundle plugin 'oh-my-fish/plugin-osx'
fundle plugin 'edc/bass'
fundle plugin 'danhper/fish-ssh-agent'
fundle plugin 'tuvistavie/fish-fastdir'
fundle plugin '0rax/fish-bd'
fundle plugin 'sentriz/fish-pipenv'
fundle plugin 'jethrokuan/fzf'
fundle plugin 'docker/cli' --path 'contrib/completion/fish'
fundle plugin 'docker/compose' --path 'contrib/completion/fish'
fundle plugin 'jorgebucaran/getopts.fish'
fundle init
