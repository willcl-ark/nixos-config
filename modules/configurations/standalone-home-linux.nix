{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  configurations.homeManager."will@linux" = {
    module.imports = with homeManager; [
      base
      desktop
      inputs.niri.homeModules.niri
      inputs.sops-nix.homeManagerModules.sops
      inputs.catppuccin.homeModules.catppuccin
      inputs.dankMaterialShell.homeModules.dank-material-shell
      inputs.dankMaterialShell.homeModules.niri
    ];
  };
}
