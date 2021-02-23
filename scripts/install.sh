# install fish
brew install fish

# install omf
curl -L https://get.oh-my.fish | fish
curl -L https://get.oh-my.fish > install

# setup
bash homebrew-install.sh
bash macsettings.sh
bash brew-tools.sh
bash brew-apps.sh

brew install neovim

# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install python/node/yarn support
pip3 install pynvim
npm i -g neovim
npm i -g yarn

# install watchman
brew install watchman

# install coc-extensions
set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails

# Install extensions
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
  echo '{"dependencies":{}}'> package.json
fi
npm install coc-prisma coc-explorer coc-tslint-plugin coc-snippets coc-json coc-cord coc-tsserver coc-eslint coc-git coc-highlight coc-prettier coc-spell-checker coc-sql coc-tabnine coc-tailwindcss coc-vimlsp --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod

# install fonts
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
 clean-up a bit
cd ..
rm -rf fonts

# install ranger
brew install ranger

# Intergrate neovim with fzf & more
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install
brew install ripgrep
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
brew install the_silver_searcher
brew install fd

# notes
echo "Thanks..."
echo "You might want to install a theme, I use zeit, (omf install zeit, omf theme zeit)"
