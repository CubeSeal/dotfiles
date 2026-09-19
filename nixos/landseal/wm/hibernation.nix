# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:

let
  niriMsg = "${pkgs.niri}/bin/niri msg action";
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

  loginctl = "${pkgs.systemd}/bin/loginctl";

  # Deliberately tests only `status`, unlike logind's own dock check
  # (manager_count_external_displays) which additionally requires the connector's
  # `enabled` sysattr to read "enabled". niri flips `enabled` to "disabled"
  # whenever it powers an output off, so logind's notion of "docked" collapses the
  # moment the OLED screen-off below fires. Here "docked" means "a monitor is
  # physically plugged in", which is independent of DPMS state.
  hasExternalDisplay = pkgs.writeShellScript "has-external-display" ''
    for c in /sys/class/drm/card*-*; do
      name=''${c##*/}
      case "''${name#*-}" in
        eDP-*|LVDS-*|DSI-*|Virtual-*|SVIDEO-*|Writeback-*) continue ;;
      esac
      [ "$(cat "$c/status" 2>/dev/null)" = connected ] && exit 0
    done
    exit 1
  '';

  # logind's three lid keys are all "ignore" (laptop.nix); acpid routes lid events
  # here instead, because logind checks docked before power and so cannot give
  # docked-on-AC and docked-on-battery different actions. `loginctl lock-sessions`
  # emits logind's Lock signal, which swayidle's `lock` handler below already
  # catches. acpid invokes this as `<script> '%e'`, but reading the ACPI lid state
  # is more robust than parsing the event string, and ignores open events.
  lidHandler = pkgs.writeShellScript "lid-handler" ''
    grep -q closed /proc/acpi/button/lid/LID0/state || exit 0

    if ${checkAC}; then
      if ${hasExternalDisplay}; then
        ${loginctl} lock-sessions
      else
        ${systemctl} suspend
      fi
    else
      ${systemctl} ${suspend_cmd}
    fi
  '';

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

  # Lid close policy, since logind cannot express it (see lidHandler above):
  #   docked + AC  -> lock          docked + battery -> suspend-then-hibernate
  #   bare   + AC  -> suspend       bare   + battery -> suspend-then-hibernate
  services.acpid = {
    enable = true;
    lidEventCommands = "${lidHandler}";
  };

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
          timeout 305  '${runOnAC "${niriMsg} power-off-monitors"}' \
            resume     '${niriMsg} power-on-monitors' \
          lock         '${lock}' \
          before-sleep '${lock}'
      '';
    };
  };
}
