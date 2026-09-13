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

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    zen-browser-stable = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.home-manager.follows = "home-manager-stable";
    };
    firefox-addons-stable = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    silentSDDM-stable = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    helium-flake-stable = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs:
    let
      system = "x86_64-linux";
      commonModules = [
        # Allow unfree packages
        { nixpkgs.config.allowUnfree = true; }
      ];
      # '//' merges 2 attribute sets with the right overriding the left.
      steamboxInputs = inputs // {
        nixpkgs        = inputs.nixpkgs-stable;
        home-manager   = inputs.home-manager-stable;
        zen-browser    = inputs.zen-browser-stable;
        firefox-addons = inputs.firefox-addons-stable;
        silentSDDM     = inputs.silentSDDM-stable;
        helium-flake   = inputs.helium-flake-stable;
      };
    in
      {
      nixosConfigurations = {
        steambox = nixpkgs-stable.lib.nixosSystem {
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
