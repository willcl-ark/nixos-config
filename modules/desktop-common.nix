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
    ./common.nix
  ];

  config = mkIf cfg.enable {
    console.keyMap = "uk";

    fonts = {
      packages = with pkgs; [
        dejavu_fonts
        font-awesome
        nerd-fonts.droid-sans-mono
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-emoji
      ];
      fontconfig.defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font"];
        sansSerif = ["DejaVu Sans"];
        serif = ["DejaVu Serif"];
      };
    };

    security.rtkit.enable = true; # For pipewire

    # Common services for both desktop environments
    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
      };
      blueman.enable = true;
      dbus.enable = true;
      udisks2 = {
        enable = true;
        mountOnMedia = true;
      };
    };
  };
}
