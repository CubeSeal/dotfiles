# vim: set tabstop=2 shiftwidth=2 expandtab:
{
  description = "NixOS System Config";

  inputs = {
    # Generic Inputs
    claude-code.url = "github:sadjow/claude-code-nix";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # Unstable Nixpkgs and derivatives

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
    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Pinned Nixpkgs for Steambox

    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    zen-browser-2605 = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-2605";
      inputs.home-manager.follows = "home-manager-2605";
    };
    firefox-addons-2605 = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    silentSDDM-2605 = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    helium-flake-2605 = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-2605, ... }@inputs:
    let
      system = "x86_64-linux";
      commonModules = [
        # Allow unfree packages
        { nixpkgs.config.allowUnfree = true; }
      ];
      # '//' merges 2 attribute sets with the right overriding the left.
      steamboxInputs = inputs // {
        nixpkgs        = inputs.nixpkgs-2605;
        home-manager   = inputs.home-manager-2605;
        zen-browser    = inputs.zen-browser-2605;
        firefox-addons = inputs.firefox-addons-2605;
        silentSDDM     = inputs.silentSDDM-2605;
        helium-flake   = inputs.helium-flake-2605;
      };
    in
      {
      nixosConfigurations = {
        steambox = nixpkgs-2605.lib.nixosSystem {
          inherit system;
          specialArgs = { inputs = steamboxInputs; };
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
