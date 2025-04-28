{ pkgs, ... }:

{
  imports = [ ./common.nix ];

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
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    mako
  ];

  security = {
    rtkit.enable = true; # For pipewire
    polkit.enable = true; # Required for Sway/Wayland
    # Required for swaylock to work
    pam.services.swaylock = { };
  };

  # Enable Wayland and Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services = {
    # Keep xserver for compatibility, but use GDM with Wayland
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
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
    gnome.gnome-keyring.enable = true;
  };
}
