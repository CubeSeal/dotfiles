# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, ... }:
{
  imports = [
    ./waybar.nix
    # Desktop Manager.
    ../dm/sddm.nix
  ];
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    everforest-cursors
    xwayland-satellite
    swayidle  # The "manager" that tracks how long you've been inactive.
    hyprlock  # The "visuals" that lock the screen.
  ];

  # Configure swayidle to manage idle behavior.
  systemd.user.services.swayidle = {
    description = "Idle Manager for Niri";
    
    # Start this service automatically whenever Niri starts.
    wantedBy = [ "niri.service" ];
    # If Niri stops (you logout), stop this service too.
    partOf = [ "niri.service" ];
    # 3. CRITICAL FIX: Wait until Niri has officially started before launching
    after = [ "niri.service" ];

    serviceConfig = {
      # 4. CRITICAL FIX: If it crashes (because Niri wasn't ready yet), try again.
      # This handles the split-second race condition where Niri is "active" 
      # but the socket isn't writable yet.
      Restart = "on-failure";
      RestartSec = "1s";
      # The command setup. 
      # We use ${pkgs...} to guarantee Nix finds the correct binary path.
      # EVENT 1: Turn off screen after 5 minutes (300 seconds)
      # EVENT 2: Sleep the PC after 10 minutes (600 seconds)
      # Note: This triggers the "suspend-then-hibernate" logic we set up earlier.
      # EVENT 3: Lock the screen before sleeping
      # This runs immediately if you close the lid OR if the 10min timer hits.
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
          timeout 600 'systemctl suspend' \
          before-sleep '${pkgs.hyprlock}/bin/hyprlock'
      '';
    };
  };
}
