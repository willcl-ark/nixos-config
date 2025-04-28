{ config, lib, pkgs, ... }:

with lib;

{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    extraOptions = [ "--unsupported-gpu" ]; # Allow Sway to work with NVIDIA
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      workspaceAutoBackAndForth = true;
      fonts = {
        names = [ "Comic Code" ];
        size = 9.0;
      };

      input = {
        "*" = {
          xkb_layout = "gb";
          natural_scroll = "enabled";
        };
      };
      focus.followMouse = false;

      output = {
        "*" = {
          scale = "2";
        };
      };

      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+q" = "kill";
          "${modifier}+d" = "exec rofi -show run";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'";
          "${modifier}+l" = "exec swaylock -f -c 000000";

          # Volume controls
          "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
          "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
          "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";

          # Brightness controls
          "XF86MonBrightnessDown" = "exec light -U 10";
          "XF86MonBrightnessUp" = "exec light -A 10";

          # Media controls
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Basic movement
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Move windows
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Switch workspaces
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          # Move containers to workspaces
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          # Layout management
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+Shift+space" = "floating toggle";
        };

      startup = [];
      bars = []; # Using waybar instead of default bar
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland-unwrapped;
    theme = "gruvbox-dark";
    extraConfig = { };
  };

  # additional Wayland utils
  home.packages = with pkgs; [
    grim # Screenshot
    playerctl # Media player controls
    slurp # Screenshot region selection
    swayidle # Idle management
    swaylock # Screen locker
    wf-recorder
    wl-clipboard
  ];

  # Fix scaling issues for various application frameworks
  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GDK_BACKEND = "wayland,x11,*";
    GDK_SCALE = "2";
    NIXOS_OZONE_WL = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  # Enable the GNOME Keyring service
  services.gnome-keyring.enable = true;
}
