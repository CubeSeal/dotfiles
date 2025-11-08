# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Nix settings
  nix = {
    settings = {
  # Flakes
      experimental-features = [ "nix-command" "flakes" ];
  # Optimise store
      auto-optimise-store = true;
    };
  # GC options
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
