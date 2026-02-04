{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.configurations.nixos;
in
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
    default = { };
  };

  config.flake.nixosConfigurations = lib.mapAttrs (
    name: value:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [ value.module ];
    }
  ) cfg;
}
