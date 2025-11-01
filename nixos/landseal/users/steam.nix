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
    # Services
    ../programs/services.nix
    # Programs and Packages
    ../programs/programs.nix
    ../programs/packages.nix
    # Steam specific
    ../programs/steam.nix
    # MDLNA
    ../programs/mdlna.nix
  ];
}
