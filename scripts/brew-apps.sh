#!/bin/sh

## MAC APPS 

PACKAGES=(
    raycast
    chrome
    iterm2
    lastpass
    docker
    notion
    spotify
)
echo "Installing Cask Packages..."
brew cask install ${PACKAGES[@]}
