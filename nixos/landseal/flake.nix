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
          modules = [ ./desktop.nix ];
          specialArgs = { inherit pkgs; };
        };
        steamos = nixpkgs.lib.nixosSystem {
          modules = [ ./steamos.nix ];
          specialArgs = { inherit pkgs; };
        };
      };    

    };
}
