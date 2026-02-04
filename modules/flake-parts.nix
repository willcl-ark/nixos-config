{ lib, ... }:
{
  options.flake.modules = {
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
    };
    homeManager = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
    };
  };
}
