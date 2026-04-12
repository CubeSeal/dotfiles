# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:
{
  # Import other modules for specific apps.
  imports = [
    # Zen browser
    ./zen.nix
  ];

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
    firefox = {
      enable = true;
      # Driver support in firefox
      # "Policies" are the enterprise way to manage Firefox. 
      # These settings will be LOCKED (you cannot change them in about:config)
      # and will show "Your browser is being managed by your organization".
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
      };
      # This section sets about:config preferences
      preferences = {
      # Force Hardware Acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "media.rdd-ffmpeg.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
    git.enable = true;
    lazygit.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    kdeconnect.enable = true;
  };

  # Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty
    stow
    grimblast
    nodejs
    qbittorrent
    fuzzel 
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jujutsu
    overskride
    tor-browser
    brightnessctl
    chromium
    nil
    mako
    calibre
    libnotify
    jjui
    sunsetr
  ];

  # Services
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    # Configure keymap in X11
    xserver.xkb = {
      layout = "au";
      variant = "";
    };
    # Printing
    printing.enable = true;
    # Printer Auto-Discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    # Enable automounting of removable media
    udisks2.enable = true;
  };
}
