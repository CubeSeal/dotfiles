# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # Waybar
    ./waybar.nix
    # Desktop Manager.
    ../dm/sddm.nix
    # Wallpaper
    ./wallpaper.nix
    # Hibernation and locking behaviour.
    ./hibernation.nix
  ];
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    everforest-cursors
    xwayland-satellite
    iio-niri  # Allows for autorotation based on sensors.
  ];

}
