# vim: set tabstop=2 shiftwidth=2 expandtab:
# Thanks to: https://github.com/VoidKeishi/nixos-config/blob/main/modules%2Fsddm.nix#L1-L34
{ lib, pkgs, inputs, ... }:
let
  wallpaperName = "wallpaper.mp4";
  wallpaper = pkgs.runCommand wallpaperName {} ''
    cp ${inputs.wallpaper} $out
      '';
in
{
  services.displayManager.sddm = {
    enable = true;
    package = lib.mkForce pkgs.kdePackages.sddm;
    wayland.enable = true;
    autoNumlock = true;
    enableHidpi = true;
    settings = {
      Theme = {
        CursorTheme = "everforest-cursors";
        CursorSize = 24;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    everforest-cursors
  ];

# Theme
  imports = [inputs.silentSDDM.nixosModules.default];
  programs.silentSDDM = {
    enable = true;
    theme = "default";
    backgrounds.wallpaper = wallpaper;
    settings = {
        "LoginScreen" = {
          background = wallpaperName;
        };
        "LockScreen" = {
          background = wallpaperName;
        };
    };
  };
}
