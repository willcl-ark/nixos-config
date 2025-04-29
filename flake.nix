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

  outputs = {
    nixpkgs,
    self,
    home-manager,
    sops-nix,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    # Helper function to generate attributes for each system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Helper to create pkgs for each system
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

    # Helper function to create host configurations
    mkHost = {
      system ? "x86_64-linux",
      hostName,
      userNames ? ["will"],
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          [
            ./hosts/default.nix # General host options
            ./hosts/${hostName}/default.nix # Host-specific config

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Configure all users specified for this host
                users = nixpkgs.lib.genAttrs userNames (user: import ./home/${user}/home.nix);
                backupFileExtension = "backup";
                extraSpecialArgs = {inherit self;};
                sharedModules = [
                  sops-nix.homeManagerModules.sops
                ];
              };
            }

            sops-nix.nixosModules.sops
          ]
          ++ extraModules;
      };

    # Helper function for standalone home-manager configurations
    mkHome = {
      system ? "x86_64-linux",
      username,
      hostname ? "unknown",
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.${system};
        modules = [
          ./home/${username}/home.nix
          sops-nix.homeManagerModules.sops
        ];
        extraSpecialArgs = {
          inherit self;
          host = hostname;
        };
      };
  in {
    # NixOS configurations
    nixosConfigurations = {
      desktop = mkHost {
        hostName = "desktop";
        userNames = ["will"];
        extraModules = [
          ./modules/desktop-environment.nix
        ];
      };
      # TODO!
      # macbook = mkHost { ... };
    };

    # Standalone home-manager configuration(s)
    # NB. home-manager is built-in to the above desktop config
    homeConfigurations = {
      "will@linux" = mkHome {
        username = "will";
        hostname = "linux";
      };
    };

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    # devShell for working on this flake
    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
        buildInputs = with nixpkgsFor.${system}; [
          nixpkgs-fmt
          nil
          sops
          ssh-to-age
        ];
      };
    });
  };
}
