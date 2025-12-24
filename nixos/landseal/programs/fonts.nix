# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
    eb-garamond
    gelasio
  ];
}
