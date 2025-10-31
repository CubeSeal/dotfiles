# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Minidlna
  minidlna = {
    enable = true;
    settings = {
      media_dir = [ "APV,/home/landseal/Movies/" ];
      friendly_name = "NixOS-Media";
      inotify = "yes";
      log_level = "error";
      announceInterval = 1;
    };
    openFirewall = true;
  };

  # Minidlna account access
  users.users.minidlna = {
    extraGroups = [ "landseal" "users" ];
  };
}
