{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, self, home-manager, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self; }; # Pass self to configuration.nix for borg
        modules = [
          ./hosts/desktop/configuration.nix
          ./hosts/desktop/hardware-configuration.nix
          ./modules/desktop-environment.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.will = import ./home/will/home.nix;
            # Backup files that would be overwritten by home-manager
            home-manager.backupFileExtension = "backup";
          }
          sops-nix.nixosModules.sops
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
