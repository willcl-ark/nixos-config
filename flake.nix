{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ned = {
      # url = "github:bitcoin-dev-tools/ned";
      url = "path:/home/will/src/bitcoin-dev-tools/ned";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:InioX/Matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    self,
    home-manager,
    sops-nix,
    catppuccin,
    niri,
    dankMaterialShell,
    matugen,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    # Helper function to generate attributes for each system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Helper to create pkgs for each system
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ niri.overlays.niri ];
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
        specialArgs = {inherit self niri dankMaterialShell matugen;};
        modules =
          [
            ./hosts/default.nix # General host options
            ./hosts/${hostName}/default.nix # Host-specific config

            # Apply niri overlay to prevent mesa sync issues
            { nixpkgs.overlays = [ niri.overlays.niri ]; }

            catppuccin.nixosModules.catppuccin
            niri.nixosModules.niri
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Configure all users specified for this host
                users = nixpkgs.lib.genAttrs userNames (user: import ./home/desktop.nix);
                backupFileExtension = "backup";
                extraSpecialArgs = {inherit self niri dankMaterialShell matugen;};
                sharedModules = [
                  sops-nix.homeManagerModules.sops
                  catppuccin.homeModules.catppuccin
                  dankMaterialShell.homeModules.dankMaterialShell
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
      configFile,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.${system};
        modules = [
          configFile
          sops-nix.homeManagerModules.sops
          catppuccin.homeModules.catppuccin
        ];
        extraSpecialArgs = {
          inherit self niri dankMaterialShell matugen;
        };
      };
  in {
    # NixOS configurations
    nixosConfigurations = {
      desktop = mkHost {
        hostName = "desktop";
        userNames = ["will"];
        extraModules = [
          ./modules/desktop-niri.nix
        ];
      };
    };

    # Standalone home-manager configuration(s)
    # NB. home-manager is built-in to the above desktop config
    homeConfigurations = {
      "will@linux" = mkHome {
        configFile = ./home/desktop.nix;
      };
      "will@macbook" = mkHome {
        system = "aarch64-darwin"; # M-series Mac
        configFile = ./home/macbook.nix;
      };
    };

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    # devShell for working on this flake
    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
        buildInputs = with nixpkgsFor.${system}; [
          alejandra
          nil
          sops
          ssh-to-age
        ];
      };
    });
  };
}
