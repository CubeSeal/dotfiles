# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      commonModules = [
        { nixpkgs.config.allowUnfree = true; }
      ];
    in
      {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./desktop.nix ] ++ commonModules;
        };
        steambox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./steambox.nix ] ++ commonModules;
        };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./laptop.nix ] ++ commonModules;
        };
      };    

    };
}
