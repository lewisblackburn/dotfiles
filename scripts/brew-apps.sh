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
    visual-studio-code
)
echo "Installing Cask Packages..."
brew cask install ${PACKAGES[@]}
