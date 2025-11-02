# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Programs
  programs = {
    nix-ld.enable = true; # Enable dynamic linking
      neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
      };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
      };
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };
    tmux.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    steam.enable = true;
    firefox.enable = true;
    git.enable = true;
    lazygit.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
