# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  # Packages
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty
    stow
    grimblast
    nodejs
    qbittorrent
    walker 
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jujutsu
    overskride
    tor-browser
    brightnessctl
    chromium
    nil
    mako
    calibre
    libnotify
    jjui
    sunsetr
  ];
}
