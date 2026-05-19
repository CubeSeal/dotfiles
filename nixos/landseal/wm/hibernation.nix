# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:

let
  pidof = "${pkgs.procps}/bin/pidof";
  niriMsg = "${pkgs.niri}/bin/niri msg action";
  hyprlockBin = "${pkgs.hyprlock}/bin/hyprlock";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  checkAC = pkgs.writeShellScript "check-ac" ''
    if grep -q "1" /sys/class/power_supply/ADP*/online 2>/dev/null; then
      exit 0
    else
      exit 1
    fi
  '';

  lock = pkgs.writeShellScript "lock-with-hyprlock" ''
    if ! ${pidof} hyprlock >/dev/null 2>&1; then
      ${hyprlockBin} >/tmp/hyprlock-swayidle.log 2>&1 &
      sleep 0.5
    fi
  '';

  runOnBattery = cmd: "${checkAC} || ${cmd}";
  runOnAC = cmd: "${checkAC} && ${cmd}";

  suspend_cmd = "suspend-then-hibernate";

in {
  environment.systemPackages = with pkgs; [
    swayidle
    hyprlock
    procps
  ];

  security.pam.services.hyprlock = {};

  systemd.user.services.swayidle = {
    description = "Idle Manager for Niri";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1s";

      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 60   '${runOnBattery "${niriMsg} power-off-monitors"}' \
          timeout 180  '${runOnBattery "${lock}"}' \
          timeout 185  '${runOnBattery "${niriMsg} power-off-monitors"}' \
            resume     '${niriMsg} power-on-monitors' \
          timeout 300  '${runOnBattery "${systemctl} ${suspend_cmd}"}' \
          timeout 300  '${runOnAC "${lock}"}' \
          timeout 900  '${runOnAC "${systemctl} ${suspend_cmd}"}' \
          lock         '${lock}' \
          before-sleep '${lock}'
      '';
    };
  };
}
