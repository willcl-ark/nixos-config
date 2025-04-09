{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/desktop/configuration.nix
          ./hosts/desktop/hardware-configuration.nix
          ./modules/desktop-environment.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.will = import ./home/will/home.nix;
          }
        ];
      };

      # Standalone home-manager configuration
      # Used by 'just update-home'
      homeConfigurations."will@linux" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/will/home.nix ];
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
