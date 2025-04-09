{ pkgs, ... }:

{
  # System-wide configuration
  environment.systemPackages = with pkgs; [
    dejavu_fonts
    font-awesome
    noto-fonts
    noto-fonts-emoji
    nerdfonts.jetbrains-mono
  ];

  console.keyMap = "uk";

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      noto-fonts
      noto-fonts-emoji
      nerdfonts.jetbrains-mono
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

  hardware = {
    bluetooth.enable = true;
    acpilight.enable = true;
  };

  security.rtkit.enable = true;
}
