{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.configurations.homeManager;
in
{
  options.configurations.homeManager = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            system = lib.mkOption {
              type = lib.types.str;
              default = "x86_64-linux";
            };
            module = lib.mkOption {
              type = lib.types.deferredModule;
            };
          };
        }
      )
    );
    default = { };
  };

  config.flake.homeConfigurations = lib.mapAttrs (
    name: value:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = value.system;
        config.allowUnfree = true;
        overlays = [ inputs.niri.overlays.niri ];
      };
      modules = [ value.module ];
    }
  ) cfg;
}
