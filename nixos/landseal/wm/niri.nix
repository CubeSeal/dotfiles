# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, lib, pkgs, inputs, ... }:
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
    iio-niri  # Allows for autorotation based on sensors.
  ];

  nixpkgs.overlays = [
    (final: prev: {
      linux-firmware = prev.linux-firmware.overrideAttrs (old: {
        # 1. Add 7zip to the build tools so we can extract the exe
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.p7zip ];

        # 2. Define the source of the driver

        # 3. Extract and copy
        postInstall = ''
          ${old.postInstall or ""}
          
          # Extract the specific bin file from the exe into a temp folder
          7z -y e ${inputs.hp_iio_driver} -o_driver_temp

          # Copy it to the destination
          cp _driver_temp/ishS_SI_5.8.0.7718.bin $out/lib/firmware/intel/ish/ish_lnlm_12128606.bin
        '';
      });
    })
  ];

  boot.kernelModules = [
    "intel-hid"
    "intel_ishtp_hid"
    "hid-sensor-hub"
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.sensor.iio.enable = true;

  # Configure swayidle to manage idle behavior.
  systemd.user.services = {
    swayidle = {
      description = "Idle Manager for Niri";
      
      # Start this service automatically whenever Niri starts.
      wantedBy = [ "graphical-session.target" ];
      # If Niri stops (you logout), stop this service too.
      partOf = [ "graphical-session.target" ];
      # 3. CRITICAL FIX: Wait until Niri has officially started before launching
      after = [ "graphical-session.target" ];

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
            timeout 595 '${pkgs.hyprlock}/bin/hyprlock &' \
            timeout 600 'systemctl suspend'
        '';
      };
    };
    # This tool listens for audio playback. If audio is playing,
    # it tells swayidle to STOP counting down.
    sway-audio-idle-inhibit = {
      description = "Prevent sleep while audio is playing";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
        Restart = "on-failure";
      };
    };
  };
}
