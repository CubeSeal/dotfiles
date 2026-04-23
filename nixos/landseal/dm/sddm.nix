# vim: set tabstop=2 shiftwidth=2 expandtab:
# Thanks to: https://github.com/VoidKeishi/nixos-config/blob/main/modules%2Fsddm.nix#L1-L34
{ lib, pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    package = lib.mkForce pkgs.kdePackages.sddm;
    wayland.enable = true;
    autoNumlock = true;
    enableHidpi = true;
  };

# Theme import
  imports = [
    # ./themes/sddm-astronaut.nix
    ./themes/silent-sddm.nix
  ];
}
