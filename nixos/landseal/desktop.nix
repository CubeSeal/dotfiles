# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hosts/desktop-hardware-configuration.nix
      # Nix settings
      ./nix.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
        # Crypto disk stuff in hardware-configuration.nix.
      };
    };
  };


  # Enable networking
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
  };
  # Wifi: Configure with nmtui or nmcli.
  # Bluetooth: Configure with overskride (installed below).
  hardware.bluetooth.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    landseal = {
      isNormalUser = true;
      description = "landseal";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      shell = pkgs.zsh;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    # SDDM
    displayManager = {
      autoLogin = {
        enable = true;
        user = "landseal";
      };
      sddm = {
        enable = true;
        theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili";
        wayland.enable = true;
        autoNumlock = true;
        extraPackages = with pkgs; [
          libsForQt5.qt5.qtquickcontrols2
          libsForQt5.qt5.qtgraphicaleffects
        ];
      };
      defaultSession = "hyprland";
    };
    # Minidlna
    minidlna = {
      enable = true;
      settings = {
        media_dir = [ "APV,/home/landseal/Movies/" ];
        friendly_name = "NixOS-Media";
        inotify = "yes";
        log_level = "error";
        announceInterval = 1;
      };
      openFirewall = true;
    };
  };

  # Minidlna account access
  users.users.minidlna = {
    extraGroups = [ "landseal" "users" ];
  };

  # Programs
  programs = {
    nix-ld.enable = true; # Enable dynamic linking
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    waybar.enable = true;
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty # Required for hyprland.
    stow
    grimblast
    hyprpaper
    nodejs
    qbittorrent
    walker 
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jujutsu
    overskride
    rose-pine-hyprcursor
    tor-browser
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
    eb-garamond
    gelasio
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
