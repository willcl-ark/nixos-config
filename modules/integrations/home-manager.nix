{ inputs, config, ... }:
let
  username = config.flake.meta.owner.username;
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.base =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username}.imports = with homeManager; [
          base
          desktop
        ];
        backupFileExtension = "backup";
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.catppuccin.homeModules.catppuccin
          inputs.dankMaterialShell.homeModules.dank-material-shell
          inputs.dankMaterialShell.homeModules.niri
        ];
      };
    };
}
