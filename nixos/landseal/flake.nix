# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true; # Allow unfree packages
        };
      };
    in
      {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system; };

          modules = [
            # Edit this configuration file to define what should be installed on
            # your system.  Help is available in the configuration.nix(5) man page
            # and in the NixOS manual (accessible by running ‘nixos-help’).
            ./desktop.nix
          ];
        };
      };    

    };
}
