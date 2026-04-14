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

# Custom user programs
  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      signing = {
        key = "~/.ssh/id_ed25519-singing.pub";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "CubeSeal";
          email = "kenndesilva1@gmail.com";
        };
        gpg.format = "ssh";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
      };
      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        '';
    };

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

    firefox = {
      enable = true;
# policies and preferences live under profiles in HM
      profiles.default = {
        isDefault = true;
        settings = {
          "media.ffmpeg.vaapi.enabled" = true;
          "media.rdd-ffmpeg.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
      };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    kitty
    grimblast
    fuzzel
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jujutsu
    jjui
    overskride
    tor-browser
    brightnessctl
    chromium
    mako
    calibre
    libnotify
    sunsetr
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
