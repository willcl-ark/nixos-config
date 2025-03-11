{ config, pkgs, lib, ... }: {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4"; # Super key
      terminal = "ghostty";
      menu = "wofi --show drun";

      # Use waybar as the default bar
      bars = [ ];

      # Define window rules
      window = {
        border = 2;
        hideEdgeBorders = "smart";
      };

      # Define keybindings
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+Return" = "exec ghostty";
          "${modifier}+d" = "exec wofi --show drun";
          "${modifier}+Shift+e" =
            "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";

          # Screenshots
          "Print" = "exec grim - | wl-copy";
          "${modifier}+Print" = ''exec grim -g "$(slurp)" - | wl-copy'';

          # Lock screen
          "${modifier}+l" = "exec swaylock -f -c 000000";
        };

      # Set up input devices
      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
        };

        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      # Set up outputs
      output = { "*" = { bg = "#000000 solid_color"; }; };

      # Start waybar
      startup = [
        { command = "waybar"; }
        { command = "mako"; } # notification daemon
        {
          command = "autotiling-rs";
        } # automatic tiling
        # Create the socket for wob (volume/brightness overlay bar)
        { command = "mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob"; }
      ];
    };

    # Extra configuration
    extraConfig = ''
      # Set a minimal timeout for idle
      exec swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock -f -c 000000'
    '';
  };

  # Configure waybar
  programs.waybar = {
    enable = true;
    # Use the custom configuration file from sway/config
    settings = builtins.fromJSON (builtins.readFile ./sway/config);
    
    # Use the custom style from sway/style.css
    style = builtins.readFile ./sway/style.css;
  };

  # Configure the notification daemon
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#2d2d2d";
    textColor = "#ffffff";
    borderColor = "#4c7899";
    borderRadius = 5;
    borderSize = 2;
    padding = "10";
    margin = "10";
  };
}

