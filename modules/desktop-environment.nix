{ pkgs, ... }:

{
  # Disable X11 services since we're using Wayland
  services.xserver.enable = false;

  # Keyboard layout
  console.keyMap = "uk";

  # Fonts configuration
  # TODO: Get my ComicCode font in here as set it as monospace
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

  # Sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # greetd display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Sway and Wayland packages
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
  };

  # Add Wayland-related packages
  environment.systemPackages = with pkgs; [
    # Base utilities
    brightnessctl
    wayland
    xdg-utils

    # Application launcher and menus
    wofi

    # Notification daemon
    mako

    # Status bar
    waybar

    # Screen locker
    swaylock
    swayidle

    # Screenshot and screen recording
    grim
    slurp
    wf-recorder

    # Image viewer and media player
    imv
    mpv

    # Volume/brightness overlay bar
    wob

    # Window management helpers
    autotiling-rs

    # Terminal
    foot
  ];

  # XDG portal for better desktop integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable dbus for service integration
  services.dbus.enable = true;

  # Ensure sway can access brightness controls without sudo
  hardware.acpilight.enable = true;
}

