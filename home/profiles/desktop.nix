{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.desktop;
in
{
  options.profiles.desktop = {
    enable = mkEnableOption "Desktop profile";
  };

  config = mkIf cfg.enable {
    # Extra graphical apps for desktop
    home.packages = with pkgs; [
      bitwarden
      firefox
      keet
      ksnip
      mullvad
      networkmanagerapplet
      pavucontrol
      signal-desktop
      telegram-desktop
      tor-browser
      vlc
    ];

  };
}
