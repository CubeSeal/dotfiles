# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./waybar.nix
    # Desktop Manager.
    ../dm/sddm.nix
    ./wallpaper.nix
  ];
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    everforest-cursors
    xwayland-satellite
    swayidle  # The "manager" that tracks how long you've been inactive.
    hyprlock  # The "visuals" that lock the screen.
    iio-niri  # Allows for autorotation based on sensors.
  ];

}
