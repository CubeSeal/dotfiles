# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  imports = [
    ./waybar.nix
  ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
