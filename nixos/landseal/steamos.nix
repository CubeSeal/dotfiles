# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hosts/desktop-hardware-configuration.nix
      # Nix settings
      ./nix.nix
      # User configuration
      ./user.nix
      # Windows Manager
      ./wm/kde.nix
    ];

  # Define a steam account. Don't forget to set a password with ‘passwd’.
  users.users = {
    steam = {
      isNormalUser = true;
      description = "steam";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ xwiimote ];
      shell = pkgs.zsh;
      initialPassword = "steam"; # Change this password!
    };
  };

  # Autologin with getty
  services.getty.autologinUser = "steam";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-866f481a-b14a-4890-af74-c8f9704569a5" = {
    device = "/dev/disk/by-uuid/866f481a-b14a-4890-af74-c8f9704569a5";
	  allowDiscards = true;
	  keyFileSize = 4096;
	  keyFile = "/dev/disk/by-id/usb-Lexar_USB_Flash_Drive_AAZQ63TST2XHL4HJ-0:0";
	  fallbackToPassword = true;
  };

  # Autologin Plasma
  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "steam";
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };

  # Enable Steam and Gamescope.
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      # Open firewall ports for Steam features.
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamescope.enable = true;
    zsh = {
      enable = true;
    };
  };

  # # Automatically start the Gamescope session on login.
  # environment.loginShellInit = ''
  #   if [ "$(tty)" = "/dev/tty1" ]; then
  #     exec ${pkgs.steam-gamescope}/bin/steam-gamescope
  #   fi
  # '';
  #

  # Enable networking
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
  };
  # Wifi: Configure with nmtui or nmcli.
  # Bluetooth: Configure with overskride (installed below).
  hardware = {
    bluetooth = {
      enable = true;
      input = {
        General = {
          ClassicBondedOnly = false;
        };
      };
    };
    steam-hardware.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  

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

