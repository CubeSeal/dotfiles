{ config, pkgs, ... }:
let
  dots = ../../..;
  conf = "${dots}/.config";
  dotfile = name: { source = "${dots}/${name}"; };
  confdir = name: { source = "${conf}/${name}"; };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "landseal";
  home.homeDirectory = "/home/landseal";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".bashrc" = dotfile ".bashrc";
    ".zshrc" = dotfile ".zshrc";
    ".vimrc" = dotfile ".vimrc";
    ".p10k.zsh" = dotfile ".p10k.zsh";
    "scripts" = dotfile "scripts";
  };

  xdg.configFile = {
    "hypr" = confdir "hypr";
    "jj" = confdir "jj";
    "kitty" = confdir "kitty";
    "niri" = confdir "niri";
    "nvim" = confdir "nvim";
    "tmux" = confdir "tmux";
    "walker" = confdir "walker";
    "waybar" = confdir "waybar";
    "mako" = confdir "mako";
    "sunsetr" = confdir "sunsetr";
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
