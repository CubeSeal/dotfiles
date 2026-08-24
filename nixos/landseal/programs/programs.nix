# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:
{
  # System level Programs
  programs = {
    nix-ld.enable = true; # Enable dynamic linking
    zsh.enable = true;
    # No nushell here: the module does not exist in the nixpkgs-2605 pin that
    # steambox uses, and nothing needs it. nushell is installed per-user by
    # home-manager/programs/nushell.nix, which is what kitty's `shell` points
    # at. zsh stays system-level so it is registered in /etc/shells -- sddm and
    # niri-session both require that to re-exec the session through the login
    # shell, which is how home-manager session variables reach the session.
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
