{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.desktop;
in {
  imports = [
    ./i3.nix
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "Desktop profile";
    desktopEnvironment = mkOption {
      type = types.enum ["gnome" "i3"];
      default = "gnome";
      description = "Which desktop environment to configure for";
    };
  };

  config = mkIf cfg.enable {
    # Enable i3 profile when i3 is selected as desktop environment  
    profiles.i3.enable = cfg.desktopEnvironment == "i3";

    # Extra graphical apps for desktop
    home.packages = with pkgs; [
      bitwarden
      firefox
      keet
      kew
      ksnip
      mullvad
      museeks
      networkmanagerapplet
      pwvucontrol
      signal-desktop
      telegram-desktop
      tor-browser
      vlc
    ];
  };
}
