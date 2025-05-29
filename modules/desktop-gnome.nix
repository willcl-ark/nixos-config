{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host.desktop;
in {
  config = mkIf (cfg.enable && cfg.environment == "gnome") {
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard
      ];

      variables = {
        MOZ_ENABLE_WAYLAND = "1"; # Enable screensharing in Firefox
        NIXOS_OZONE_WL = "1"; # Wayland support for electron apps + Chrome
      };
    };

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
