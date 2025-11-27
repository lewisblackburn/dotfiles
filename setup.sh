#!/bin/bash
# macOS Development Environment Setup Script
# Simple, readable, and easy to update

set -e  # Exit on error

echo "🚀 Starting macOS setup..."

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "🔧 Adding Homebrew to PATH..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

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
echo "📦 Installing CLI tools..."
brew install neovim
brew install starship
brew install nvm
brew install deno

# Setup nvm
echo "🔧 Setting up nvm..."
mkdir -p ~/.nvm
cat >> ~/.zshrc << 'EOF'

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
EOF

# Install JankyBorders
echo "📦 Installing JankyBorders..."
brew tap FelixKratz/formulae
brew install borders

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Setting zsh as default shell..."
    chsh -s $(which zsh)
else
    echo "✅ zsh already default shell"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your terminal (or source ~/.zshrc)"
echo "  2. Install Node.js via nvm: nvm install --lts"
echo "  3. Configure yadm: yadm clone <your-dotfiles-repo>"
echo "  4. Configure your applications (Aerospace, Karabiner, etc.)"
echo "  5. Start JankyBorders: brew services start borders"
echo ""
