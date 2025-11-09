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
    hyprpaper
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
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
    eb-garamond
    gelasio
  ];
}
