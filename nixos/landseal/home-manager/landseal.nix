{ config, pkgs, inputs, ... }:
let
  dots = ../../..;
  conf = "${dots}/.config";
  dotfile = name: { source = "${dots}/${name}"; };
  confdir = name: { source = "${conf}/${name}"; };
  gitUser = "CubeSeal";
  gitEmail = "kenndesilva1@gmail.com";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "landseal";
  home.homeDirectory = "/home/landseal";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".bashrc" = dotfile ".bashrc";
    ".p10k.zsh" = dotfile ".p10k.zsh";
  };

  xdg.configFile = {
    "hypr" = confdir "hypr";
    "kitty" = confdir "kitty";
    "niri" = confdir "niri";
    "tmux" = confdir "tmux";
    "quickshell" = confdir "quickshell";
    # waybar / walker / mako are now superseded by the quickshell config above.
    # Their dotfiles are kept under .config/ as a fallback but are no longer
    # symlinked into place. Re-add the corresponding entries here to revert.
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];


# Custom user programs
  imports = [
    ./programs/zen.nix
    ./programs/firefox.nix
    ./programs/zsh.nix
    (import ./programs/git.nix {gitUser=gitUser; gitEmail=gitEmail;})
    (import ./programs/jj.nix {gitUser=gitUser; gitEmail=gitEmail;})
    ./programs/claude-code.nix
    ./programs/quickshell.nix
    ./programs/neovim.nix
  ];

  programs = {
    home-manager.enable = true;

    tmux.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    lazygit.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    chromium = {
      enable = true;
      package = pkgs.chromium.override { enableWideVine = true; };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    kitty
    grimblast
    grim          # used by the quickshell lock screen to grab a pre-lock screenshot
    fuzzel
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jjui
    overskride
    tor-browser
    brightnessctl
    calibre
    libnotify
    nodejs
    qbittorrent
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
