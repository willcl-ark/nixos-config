{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host.desktop;
in {
  imports = [
    ./desktop-common.nix
    ./desktop-gnome.nix
    ./desktop-i3.nix
  ];

  options.host.desktop = {
    enable = mkEnableOption "desktop environment";
    environment = mkOption {
      type = types.enum ["gnome" "i3"];
      default = "gnome";
      description = "Which desktop environment to use";
    };
  };
}
