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
    # Tablet mode: on-screen keyboard and touchscreen gestures.
    ./tablet.nix
    # Hibernation and locking behaviour.
    ./hibernation.nix
  ];
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    everforest-cursors
    xwayland-satellite
  ];

}
