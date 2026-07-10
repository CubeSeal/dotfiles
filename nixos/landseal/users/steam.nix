# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Define a steam account. Don't forget to set a password with ‘passwd’.
  users.users = {
    steam = {
      isNormalUser = true;
      description = "steam";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ xwiimote ];
      shell = pkgs.zsh;
      initialPassword = "steam"; # Change this password!
    };
  };

  # Import other modules.
  imports = [
    # Programs, packages, and services (all folded into programs.nix)
    ../programs/programs.nix
    # Steam specific
    ../programs/steam.nix
    # MDLNA
    ../programs/minidlna.nix
  ];
}
