{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  # System-wide configuration
  console.keyMap = "uk";

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      noto-fonts
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    blueman.enable = true;
    dbus.enable = true;
  };
}
