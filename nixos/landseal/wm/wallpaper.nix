# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, inputs, ... }:
let
  # Pull the desktop wallpaper from the same flake input the login screen uses
  # (see dm/themes/silent-sddm.nix).
  wallpaperVideo = pkgs.runCommand "wallpaper.mp4" {} ''
    cp ${inputs.wallpaper} $out
  '';

  # Pre-render the static frame at build time so the runtime closure does not
  # need ffmpeg and the first --start is instant.
  wallpaperStatic = pkgs.runCommand "wallpaper.png" {
    nativeBuildInputs = [ pkgs.ffmpeg ];
  } ''
    ffmpeg -y -i ${wallpaperVideo} -vframes 1 -f image2 $out
  '';

  toggleWallpaper = pkgs.writeShellApplication {
    name = "toggle-wallpaper";
    runtimeInputs = with pkgs; [ mpvpaper awww procps util-linux coreutils ];
    text = ''
      # === CONFIGURATION ===
      # Animated source (MP4) and its pre-rendered static frame, both from the
      # nix store via the flake input.
      WALLPAPER_PATH="${wallpaperVideo}"
      STATIC_PATH="${wallpaperStatic}"

      start_awww_daemon() {
          if ! pgrep -x "awww-daemon" > /dev/null; then
              printf '%s\n' "awww is not running. Starting awww..."
              # Detach so the daemon outlives this (niri-spawned) toggle process.
              setsid -f awww-daemon > /dev/null 2>&1
              # Wait until the daemon's IPC is ready before sending an image.
              for _ in $(seq 1 50); do
                  awww query > /dev/null 2>&1 && break
                  sleep 0.1
              done
          fi
          awww img -a "$STATIC_PATH" -t "none" > /dev/null 2>&1 || true
      }

      if [[ ''${1:-} == '--start' ]]; then

          pkill mpvpaper > /dev/null 2>&1 || true
          pkill awww-daemon > /dev/null 2>&1 || true

          start_awww_daemon

          exit 0

      elif [[ ''${1:-} == '--toggle' ]]; then

          # Match the filename so we don't kill unrelated instances.
          if pgrep -f "mpvpaper.*$WALLPAPER_PATH" > /dev/null; then
              printf '%s\n' "Stopping animated wallpaper..."
              start_awww_daemon
              pkill mpvpaper || true
          else
              printf '%s\n' "Starting animated wallpaper..."
              # Optimized flags (GPU usage + Fill screen).
              mpvpaper -pf -o "no-audio --loop-file=inf --hwdec=auto --panscan=1.0" ALL "$WALLPAPER_PATH"
              sleep 1
              pkill awww-daemon || true
          fi

          exit 0
      else
          printf '%s\n' "Usage: toggle-wallpaper [--start|--toggle]"
          exit 1
      fi
    '';
  };
in
{
  environment.systemPackages = [ toggleWallpaper ];
}
