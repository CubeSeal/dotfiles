# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:
{
  # System level Programs
  programs = {
    nix-ld.enable = true; # Enable dynamic linking
    zsh.enable = true;
    nushell.enable = true;
    steam.enable = true;
    kdeconnect.enable = true;
  };

  # Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    nil
    vim
  ];

  # Services
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    # Configure keymap in X11
    xserver.xkb = {
      layout = "au";
      variant = "";
    };
    # Printing
    printing.enable = true;
    # Printer Auto-Discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    # Enable automounting of removable media
    udisks2.enable = true;
  };
}
