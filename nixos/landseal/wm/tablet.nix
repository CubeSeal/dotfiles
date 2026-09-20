# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:
let
  # GGEZUS/niri-tablet: a patch series against niri v26.04 adding multi-finger
  # touchscreen gestures. Pinned to a tag, never main -- the patches only apply
  # to the niri version they were generated against, so a niri bump past 26.04
  # will fail loudly at build time rather than silently drop the gestures.
  niri-tablet-src = pkgs.fetchFromGitHub {
    owner = "GGEZUS";
    repo = "niri-tablet";
    rev = "v26.04.18";
    hash = "sha256-yceNeLKcv7HNc2UxkP+Ka1oa9Zx96OhYUvlESzYVI3s=";
  };

  # The series touches only src/ and niri-config/src/ -- no Cargo.toml or
  # Cargo.lock -- so the vendored dependency hash stays valid and plain
  # overrideAttrs is enough.
  niri-tablet = pkgs.niri.overrideAttrs (prev: {
    postPatch = (prev.postPatch or "") + ''
      for p in ${niri-tablet-src}/pkg/*.patch; do
        echo "niri-tablet: applying $(basename "$p")"
        patch -Np1 < "$p"
      done
    '';
  });

  # wvkbd --auto only fires for clients speaking text-input-v3; many terminals
  # and Electron apps never do, so keep a manual toggle. SIGRTMIN toggles
  # visibility (SIGUSR1 hides, SIGUSR2 shows).
  toggleOsk = pkgs.writeShellApplication {
    name = "toggle-osk";
    runtimeInputs = with pkgs; [ procps ];
    text = ''
      # || true so the bind is a no-op rather than an error when the daemon
      # isn't running. Flags live in .config/niri/config.kdl so -H/-L stay
      # tunable without a rebuild.
      pkill --signal RTMIN wvkbd-mobintl || true
    '';
  };
in
{
  programs.niri.package = niri-tablet;

  environment.systemPackages = [
    pkgs.wvkbd  # provides wvkbd-mobintl; nixpkgs builds this layout only
    toggleOsk
  ];
}
