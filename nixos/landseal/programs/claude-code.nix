# vim: set tabstop=2 shiftwidth=2 expandtab:
{ pkgs, inputs, ... }:
{

  nix.settings = {
    extra-substituters = [ "https://claude-code.cachix.org" ];
    extra-trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  environment.systemPackages = with inputs; [
    claude-code.packages.${pkgs.system}.default
  ];
}
