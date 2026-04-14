# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, inputs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    landseal = {
      isNormalUser = true;
      description = "landseal";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };
  };

  # Import other modules.
  imports = [
    # Programs and Packages
    ../programs/programs.nix
    # Fonts
    ../programs/fonts.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Set your time zone.
  # Dynamic time-zone
  services.automatic-timezoned.enable = true;
  # time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.landseal = ../home-manager/landseal.nix;
  };
 
}
