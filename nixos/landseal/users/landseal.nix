# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    landseal = {
      isNormalUser = true;
      description = "landseal";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      shell = pkgs.zsh;
    };
  };

  # Import other modules.
  imports = [
    # Services
    ../programs/services.nix
    # Programs and Packages
    ../programs/programs.nix
    ../programs/packages.nix
  ];
}
