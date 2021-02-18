#!/bin/sh

## BREW TOOLS 

PACKAGES=(
    fish 
    git
    wget
    tree
    docker
    postgresql
    neofetch
    redis
    neovim
    node
    yarn
    ranger
)
echo "Installing Brew Packages..."
brew install ${PACKAGES[@]}
