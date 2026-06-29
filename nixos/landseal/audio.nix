# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, inputs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.pipewire = {
    enable = true;
    # PulseAudio compatibility layer. Firefox/Zen, Discord, and most
    # desktop apps talk PulseAudio, so this is what they actually use.
    pulse.enable = true;
    # ALSA compatibility, for apps that talk ALSA directly.
    alsa.enable = true;

    wireplumber = {
      enable = true;
      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          # mSBC: 16kHz wideband speech codec for HFP (the mic profile).
          # Without it the mic falls back to 8kHz CVSD and sounds like
          # a phone call from 1995.
          "bluez5.enable-msbc" = true;
          # SBC-XQ: higher-bitrate SBC for A2DP playback. Playback only,
          # no effect on the mic.
          "bluez5.enable-sbc-xq" = true;
          # Let the headphones handle volume in hardware instead of
          # scaling in software.
          "bluez5.enable-hw-volume" = true;

          # No roles line. The old "bluez5.headset-roles" property was
          # renamed to "bluez5.roles" in WirePlumber 0.5, so the previous
          # line here was ignored. The default roles already include
          # hfp_hf, which is what provides the mic. Upstream deliberately
          # excludes hsp_ag because Sony WH-1000XM3/XM4 misbehave when
          # hsp_ag and hfp_ag are both enabled. Do not re-add it.
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # GUI for switching the card profile between A2DP (playback only)
    # and Headset Head Unit (playback + mic). WirePlumber auto-switches
    # when an app opens the mic, but manual switching here is the first
    # debugging step when a call app can't see the mic.
    pwvucontrol
  ];
}
