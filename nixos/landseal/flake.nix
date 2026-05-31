# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wallpaper = {
      url = "https://www.desktophut.com/files/ieMNgswbJB-Wallpaper12Prob4.mp4";
      flake = false;
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-2511, ... }@inputs:
    let
      system = "x86_64-linux";
      commonModules = [ { nixpkgs.config.allowUnfree = true; } ];
    in
      {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./desktop.nix ] ++ commonModules;
        };
        steambox = nixpkgs-2511.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
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
