# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true; # Allow unfree packages
        };
      };
    in
      {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system; };

          modules = [
            # Edit this configuration file to define what should be installed on
            # your system.  Help is available in the configuration.nix(5) man page
            # and in the NixOS manual (accessible by running ‘nixos-help’).

            ({ config, pkgs, ... }:

              {
                imports =
                  [ # Include the results of the hardware scan.
                    ./hardware-configuration.nix
                  ];

                # Flakes
                nix.settings.experimental-features = [ "nix-command" "flakes" ];

                # Bootloader.
                boot.loader.grub.enable = true;
                boot.loader.grub.device = "/dev/sda";
                boot.loader.grub.useOSProber = true;

                boot.initrd.luks.devices."luks-7af26863-041e-4fde-9fa7-de9ccbfcadd4".device = "/dev/disk/by-uuid/7af26863-041e-4fde-9fa7-de9ccbfcadd4";
                # Setup keyfile
                boot.initrd.secrets = {
                  "/boot/crypto_keyfile.bin" = null;
                };

                boot.loader.grub.enableCryptodisk = true;

                boot.initrd.luks.devices."luks-cc063602-d5a0-42d9-9a37-13fa40992cda".keyFile = "/boot/crypto_keyfile.bin";
                boot.initrd.luks.devices."luks-7af26863-041e-4fde-9fa7-de9ccbfcadd4".keyFile = "/boot/crypto_keyfile.bin";

                networking.hostName = "nixos"; # Define your hostname.

                # Automated garbage collector
                nix.settings.auto-optimise-store = true;
                nix.gc.automatic = true;
                nix.gc.dates = "weekly";
                nix.gc.options = "--delete-older-than 30d";

                # Enable networking
                networking.networkmanager.enable = true;
                # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
                # Configure network proxy if necessary
                # networking.proxy.default = "http://user:password@proxy:port/";
                # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

                # Set your time zone.
                time.timeZone = "Australia/Sydney";

                # Select internationalisation properties.
                i18n.defaultLocale = "en_AU.UTF-8";

                i18n.extraLocaleSettings = {
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

                # Define a user account. Don't forget to set a password with ‘passwd’.
                users.users.landseal = {
                  isNormalUser = true;
                  description = "landseal";
                  extraGroups = [ "networkmanager" "wheel" ];
                  packages = with pkgs; [];
                  shell = pkgs.zsh;
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
                  };
                  zsh = {
                    enable = true;
                    enableCompletion = true;
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

                # Some programs need SUID wrappers, can be configured further or are
                # started in user sessions.
                # programs.mtr.enable = true;
                # programs.gnupg.agent = {
                #   enable = true;
                #   enableSSHSupport = true;
                # };

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

              })
          ];
        };
      };    

    };
}
