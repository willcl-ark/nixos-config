{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  configurations.homeManager."will@macbook" = {
    system = "aarch64-darwin";
    module.imports = with homeManager; [
      base
      macbook
      inputs.sops-nix.homeManagerModules.sops
      inputs.catppuccin.homeModules.catppuccin
    ];
  };
}
