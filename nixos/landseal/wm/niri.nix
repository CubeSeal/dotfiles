# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  imports = [ ./waybar.nix ];
  programs.niri.enable = true;
  services.iio-niri.enable = true;

  environment.systemPackages = with pkgs; [
    everforest-cursors
  ];
}
