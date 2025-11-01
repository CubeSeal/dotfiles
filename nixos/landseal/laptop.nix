# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hosts/laptop-hardware-configuration.nix
      # Nix settings
      ./nix.nix
      # User configuration
      ./users/landseal.nix
      # Windows Manager
      ./wm/hyprland.nix
      # Desktop Manager.
      ./dm/sddm.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Autologin display manager
  services.displayManager.autoLogin = {
    enable = true;
    user = "landseal";
    defaultSession = "hyprland";
  };

  # Laptop specific settings
  # TLP for power savings.
  services.tlp.enable = true;

  # Enable networking
  networking = {
    hostName = "nixos-laptop"; # Define your hostname.
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
