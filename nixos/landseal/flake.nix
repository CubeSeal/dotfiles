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
    claude-code.url = "github:sadjow/claude-code-nix";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # --- steambox (pinned-stable) input set ---
    # steambox is pinned to NixOS 26.05. Every unstable-following input its
    # shared home-manager tree consumes gets a 26.05-matched variant here, wired
    # in per-host via `steamboxInputs` below. See CLAUDE.md.
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
    # No nixCats-2605: nixCats exposes no `nixpkgs` input to follow, so a variant
    # would just duplicate the base input. steambox shares `nixCats`; its neovim
    # plugins are already built against nixpkgs-2605 via `nixpkgs_version =
    # inputs.nixpkgs` in home-manager/programs/neovim.nix.
    silentSDDM-2605 = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-2605, ... }@inputs:
    let
      system = "x86_64-linux";
      commonModules = [ { nixpkgs.config.allowUnfree = true; } ];
      # steambox's view of `inputs`: the same attrset, but with every
      # unstable-following input replaced by its 26.05-matched variant. Because
      # every shared module references these by name (inputs.home-manager,
      # inputs.zen-browser, ...), the whole tree flavors to 26.05 for steambox
      # with no per-module changes; laptop keeps the plain unstable `inputs`.
      steamboxInputs = inputs // {
        nixpkgs        = inputs.nixpkgs-2605;
        home-manager   = inputs.home-manager-2605;
        zen-browser    = inputs.zen-browser-2605;
        firefox-addons = inputs.firefox-addons-2605;
        silentSDDM     = inputs.silentSDDM-2605;
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
