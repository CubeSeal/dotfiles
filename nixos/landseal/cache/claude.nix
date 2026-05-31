# vim: set tabstop=2 shiftwidth=2 expandtab:
{ ... }:
{
  # Substituter/key for the claude-code flake build. The package itself is
  # installed via home-manager (home-manager/programs/claude-code.nix).
  nix.settings = {
    extra-substituters = [ "https://claude-code.cachix.org" ];
    extra-trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };
}
