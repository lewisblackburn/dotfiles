#!/bin/bash

# macOS Development Environment Setup Script
# Simple, readable, and easy to update

set -e  # Exit on error

echo "🚀 Starting macOS setup..."

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed"
fi

# Install yadm
echo "📦 Installing yadm..."
brew install yadm

# Install zsh (usually pre-installed on macOS)
echo "📦 Ensuring zsh is installed..."
brew install zsh

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh already installed"
fi

# Install applications via Homebrew
echo "📦 Installing applications..."

brew install --cask aerospace
brew install --cask iterm2
brew install --cask karabiner-elements
brew install --cask raycast

# Install CLI tools
brew install neovim
brew install starship

# Install JankyBorders
brew tap FelixKratz/formulae
brew install borders

echo ""
echo "✨ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Set zsh as default shell: chsh -s $(which zsh)"
echo "  2. Configure yadm: yadm clone <your-dotfiles-repo>"
echo "  3. Restart your terminal"
echo "  4. Configure your applications"
echo ""
