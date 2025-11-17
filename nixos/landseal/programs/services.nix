# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Services
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    # Configure keymap in X11
    xserver.xkb = {
      layout = "au";
      variant = "";
    };
    # Printing
    printing.enable = true;
    # Printer Auto-Discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    # Enable automounting of removable media
    udisks2.enable = true;
  };
}
