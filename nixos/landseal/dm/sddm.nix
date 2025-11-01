# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, ... }:

{
  # SDDM
  services.displayManager = {
    sddm = {
      enable = true;
      theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili";
      wayland.enable = true;
      autoNumlock = true;
      extraPackages = with pkgs; [
        libsForQt5.qt5.qtquickcontrols2
        libsForQt5.qt5.qtgraphicaleffects
      ];
    };
    defaultSession = "hyprland";
  };
}
