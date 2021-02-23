" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    Plug 'sheerun/vim-polyglot'                                           " Better Syntax Support
    Plug 'scrooloose/NERDTree'                                            " File Explorer
    Plug 'jiangmiao/auto-pairs'                                           " Auto pairs for '(' '[' '{'
    Plug 'arcticicestudio/nord-vim'                                       " Theme
    Plug 'neoclide/coc.nvim', {'branch': 'release'}                       " Stable version of coc
    Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}    " Keeping up to date with master
    Plug 'vim-airline/vim-airline'                                        " Airline and Airline Themes
    Plug 'vim-airline/vim-airline-themes'                                 " Fuzzy Finder
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'airblade/vim-rooter'
    Plug 'tpope/vim-commentary'                                           " comment out lines
    Plug 'mhinz/vim-startify'
    Plug 'mhinz/vim-signify'                                              " Git
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    Plug 'junegunn/gv.vim'
    Plug 'unblevable/quick-scope'                                         " Navigate Text
    Plug 'justinmk/vim-sneak'
    Plug 'honza/vim-snippets'
    Plug 'tinyheero/vim-myhelp'                                           " Personal vim-cheatsheet
    Plug 'junegunn/goyo.vim'
    Plug 'voldikss/vim-floaterm'
    Plug 'pantharshit00/vim-prisma'
call plug#end()


