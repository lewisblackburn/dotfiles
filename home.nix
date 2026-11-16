{ config, pkgs, ... }:

let
  # Link straight to the repo, so edits apply without a rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
in
{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Shell and terminal
    tmux starship zoxide fzf sesh
    # Neovim and what LazyVim needs
    neovim tree-sitter ripgrep fd lazygit
    # Git, runtimes, database client for nvim's DB UI
    git delta mise mysql84
  ];

  # Home Manager writes ~/.zshrc with the plugins, then hands over to our file.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = "source ~/dotfiles/zsh/zshrc";
  };

  xdg.configFile = {
    "ghostty/config".source = link "ghostty/config";
    "tmux/tmux.conf".source = link "tmux/tmux.conf";
    "starship.toml".source = link "starship.toml";
    "nvim".source = link "nvim";
    "mise/config.toml".source = link "mise/config.toml";
    "git/config".source = link "git/config";
    "git/ignore".source = link "git/ignore";
  };
}
