# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, ... }:
{
  # quickshell is in nixpkgs (same 0.3.0 as the upstream flake) and prebuilt in
  # cache.nixos.org, so we use pkgs.quickshell rather than a flake input: no
  # from-source compile, no extra substituter. The QML config lives in
  # ../../../.config/quickshell and is symlinked via xdg.configFile in landseal.nix.
  home.packages = with pkgs; [
    quickshell
    # Runtime helpers the QML shell shells out to.
    libqalculate     # `qalc` — inline calculator in the launcher
    procps           # pkill/pgrep used by the bar toggle path
  ];
}
