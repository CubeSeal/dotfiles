# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      commonModules = [
        { nixpkgs.config.allowUnfree = true; }
      ];
    in
      {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          modules = [ ./desktop.nix ] ++ commonModules;
        };
        steambox = nixpkgs.lib.nixosSystem {
          modules = [ ./steambox.nix ] ++ commonModules;
        };
        laptop = nixpkgs.lib.nixosSystem {
          modules = [ ./laptop.nix ] ++ commonModules;
        };
      };    

    };
}
