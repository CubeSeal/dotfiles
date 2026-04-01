# vim: set tabstop=2 shiftwidth=2 expandtab:
# Thanks to Claude I guess.
{ config, pkgs, inputs, ... }:
{
  services.pipewire = {
    enable = true;

    # Compatibility layer so apps that speak PulseAudio (Firefox, Discord, etc.)
    # work without modification.
    pulse.enable = true;

    # Low-level ALSA support — lets ALSA-native apps go through PipeWire too.
    alsa.enable = true;

    wireplumber = {
      enable = true;

      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          # mSBC: wideband speech codec for the mic (16kHz vs 8kHz narrowband).
          # Required for the mic to sound intelligible.
          "bluez5.enable-msbc" = true;

          # SBC-XQ: higher quality variant of the standard SBC audio codec.
          # Improves A2DP playback quality slightly.
          "bluez5.enable-sbc-xq" = true;

          # Let the headphones control their own hardware volume
          # rather than doing it in software.
          "bluez5.enable-hw-volume" = true;

          # Advertise all headset roles so the system can negotiate
          # HFP (Hands-Free Profile) which is what activates the mic.
          # Without this, it defaults to A2DP-only (playback, no mic).
          "bluez5.headset-roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pwvucontrol   # GUI for switching audio profiles (A2DP ↔ Headset Head Unit)
  ];}
