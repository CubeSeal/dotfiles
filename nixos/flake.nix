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
                nixos = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };

                    modules = [
                        ./nixos/configuration.nix
                    ];
                };
            };    

        };
}
