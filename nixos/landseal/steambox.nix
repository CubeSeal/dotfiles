# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hosts/desktop-hardware-configuration.nix
      # Nix settings
      ./nix.nix
      # User configuration
      ./users/landseal.nix
      ./users/steam.nix
      # Windows Manager
      ./wm/kde.nix
    ];

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
  services.displayManager.autoLogin = {
    enable = true;
    user = "steam";
  };

  # Enable networking
  networking = {
    hostName = "nixos-steambox"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Wifi: Configure with nmtui or nmcli.
  # Bluetooth: Configure with overskride (installed below).
  hardware.bluetooth.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Time zone and locale are managed in users/landseal.nix
  # (services.automatic-timezoned + i18n).

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

