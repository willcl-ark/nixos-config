{pkgs, ...}: {
  imports = [./common.nix];

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

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  security.rtkit.enable = true; # For pipewire

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
