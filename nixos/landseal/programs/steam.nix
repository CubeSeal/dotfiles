# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
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

  # Controller Settings
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
}
