# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:

let
  niriMsg = "${pkgs.niri}/bin/niri msg action";
  hyprlockBin = "${pkgs.hyprlock}/bin/hyprlock";
  qsBin = "${pkgs.quickshell}/bin/qs";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  checkAC = pkgs.writeShellScript "check-ac" ''
    if grep -q "1" /sys/class/power_supply/ADP*/online 2>/dev/null; then
      exit 0
    else
      exit 1
    fi
  '';

  # The quickshell lock is now the active auto-locker for every path (idle
  # timeout, before-sleep, and the logind `lock` event) as well as the niri
  # Super+Alt+L keybind. `qs ipc call lock lock` only sends the IPC and returns
  # immediately; the QML lock() grabs a screenshot with grim asynchronously and
  # engages the ext-session-lock in grim's onExited callback. The `sleep 0.5`
  # (mirroring the guard hyprlock used) keeps swayidle's `-w` sleep inhibitor held
  # until the lock surface is mapped, so before-sleep can't suspend a beat early
  # and flash the desktop on resume. hyprlock (${hyprlockBin}) is left installed
  # as a manual fallback.
  lock = pkgs.writeShellScript "lock-with-qs" ''
    ${qsBin} ipc call lock lock
    sleep 0.5
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

  # hyprlock is the active auto-locker; quickshell is the one being trialled via
  # Super+Alt+L. Both PAM services are present so either can authenticate.
  security.pam.services.hyprlock = {};
  security.pam.services.quickshell = {};

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
