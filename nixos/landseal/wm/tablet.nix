# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, inputs, ... }:
let
  # GGEZUS/niri-tablet: a patch series against niri v26.04 adding multi-finger
  # touchscreen gestures. Pinned to a tag in flake.nix, never main -- the
  # patches only apply to the niri version they were generated against, so a
  # niri bump past 26.04 fails loudly at build time rather than silently
  # dropping the gestures.
  #
  # The series touches only src/ and niri-config/src/ -- no Cargo.toml or
  # Cargo.lock -- so the vendored dependency hash stays valid and plain
  # overrideAttrs is enough.
  niri-tablet = pkgs.niri.overrideAttrs (prev: {
    postPatch = (prev.postPatch or "") + ''
      for p in ${inputs.niri-tablet}/pkg/*.patch; do
        echo "niri-tablet: applying $(basename "$p")"
        patch -Np1 < "$p"
      done
    '';
  });

  # Keyboard geometry. It lives here rather than in config.kdl because
  # switch-events can only spawn a command, not pass flags through it.
  # Changing these rebuilds only this script -- niri is untouched.
  portraitHeight = "600";
  landscapeHeight = "300";

  # wvkbd cannot turn --auto on or off at runtime, so switching modes means
  # restarting it. --auto is confined to tablet mode: in laptop mode it would
  # summon the keyboard every time you focused a text field with the physical
  # keyboard.
  oskMode = pkgs.writeShellApplication {
    name = "osk-mode";
    runtimeInputs = with pkgs; [ procps util-linux wvkbd ];
    text = ''
      pkill -x wvkbd-mobintl || true

      case "''${1:-off}" in
        on)
          # Tablet mode: pop up on text-input-v3 focus.
          setsid wvkbd-mobintl --auto --hidden \
            -H ${portraitHeight} -L ${landscapeHeight} >/dev/null 2>&1 &
          ;;
        off)
          # Laptop mode: no --auto. Mod+G and the bottom-edge swipe still work.
          setsid wvkbd-mobintl --hidden \
            -H ${portraitHeight} -L ${landscapeHeight} >/dev/null 2>&1 &
          ;;
        *)
          echo "usage: osk-mode [on|off]" >&2
          exit 1
          ;;
      esac
    '';
  };

  # --auto only fires for clients speaking text-input-v3; many terminals and
  # Electron apps never do, and in laptop mode it is off entirely. SIGRTMIN
  # toggles visibility (SIGUSR1 hides, SIGUSR2 shows).
  toggleOsk = pkgs.writeShellApplication {
    name = "toggle-osk";
    runtimeInputs = with pkgs; [ procps ];
    text = ''
      # || true so the bind is a no-op rather than an error when the daemon
      # isn't running.
      pkill --signal RTMIN wvkbd-mobintl || true
    '';
  };
in
{
  programs.niri.package = niri-tablet;

  environment.systemPackages = [
    pkgs.wvkbd  # provides wvkbd-mobintl; nixpkgs builds this layout only
    oskMode
    toggleOsk
  ];
}
