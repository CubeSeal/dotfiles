# vim: set tabstop=2 shiftwidth=2 expandtab:
# Thanks to: https://github.com/VoidKeishi/nixos-config/blob/main/modules%2Fsddm.nix#L1-L34
{ config, pkgs, inputs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
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
    backgrounds = {
      forest = pkgs.fetchurl {
        name = "wallpaper.mp4";
        url = "https://go.moewalls.com/download.php?video=PfJbjX0KEuoI91r5npEdSFrGxKRdlPgOFh80qrO%2Fr2MauWDMVtbF9%2FYMUbDKS5tvojdnWsfLMQV%2BBojC";
        hash = "sha256-jCa8bVspeOsAMcUne3DQS+g8rj0byHCA9WQWHXNLccI=";
      };
    };
    settings = {
        "LoginScreen" = {
          background = "wallpaper.mp4";
        };
        "LockScreen" = {
          background = "wallpaper.mp4";
        };
    };
  };
}
