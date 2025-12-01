# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
   environment.systemPackages = with pkgs; [ 
    mpvpaper
    swww
    ffmpeg
    socat
  ];
}
