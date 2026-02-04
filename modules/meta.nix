{ lib, ... }:
{
  options.flake.meta.owner = {
    username = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.flake.meta.owner.username = "will";
}
