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
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          # "temperature"
          "battery"
          "clock"
          "tray"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "clock" = {
          format = "{:%H:%M %d/%m/%Y}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };

        "cpu" = { format = "CPU {usage}% "; };

        "memory" = { format = "RAM {}% "; };

        "battery" = { format = "BAT {capacity}% "; };

        "network" = {
          format-wifi = "WiFi ({signalStrength}%) ";
          format-ethernet = "ETH ";
          format-disconnected = "Disconnected ";
        };

        "pulseaudio" = {
          format = "VOL {volume}% ";
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 13px;
      }

      window#waybar {
        background: #2d2d2d;
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: #ffffff;
        border-bottom: 3px solid transparent;
      }

      #workspaces button.focused {
        background: #444444;
        border-bottom: 3px solid #ffffff;
      }
    '';
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

