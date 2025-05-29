{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.i3;
in {
  options.profiles.i3 = {
    enable = mkEnableOption "i3 window manager profile";
  };

  config = mkIf cfg.enable {
    # i3-specific packages
    home.packages = with pkgs; [
      dunst
      gnome-keyring
    ];

    # i3-specific environment variables for HiDPI scaling
    home.sessionVariables = {
      # Qt applications
      QT_SCALE_FACTOR = "2";
      QT_AUTO_SCREEN_SCALE_FACTOR = "0";

      # GTK applications
      GDK_SCALE = "2";
      GDK_DPI_SCALE = "0.5"; # 1/2 to counteract font scaling

      # Cursor size
      XCURSOR_SIZE = "32"; # Default 16 * 2
    };

    # Xresources for additional X11 applications
    xresources.properties = {
      "Xft.dpi" = 192; # Match system DPI setting
      "Xcursor.size" = 32;
    };

    # GNOME Keyring service for i3
    services.gnome-keyring = {
      enable = true;
      components = ["secrets" "ssh"];
    };

    # i3 window manager configuration
    xsession.windowManager.i3 = {
      enable = true;

      config = {
        modifier = "Mod4"; # Super key

        # Font for i3 UI
        fonts = {
          names = ["DejaVu Sans Mono"];
          size = 8.0;
        };

        # Default terminal
        terminal = "${pkgs.ghostty}/bin/ghostty";

        # Menu (rofi)
        menu = "${pkgs.rofi}/bin/rofi -show drun";

        # Startup commands
        startup = [
          {
            command = "dbus-update-activation-environment --all";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.xorg.xsetroot}/bin/xsetroot -solid '#282828'";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.playerctl}/bin/playerctld daemon";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.dunst}/bin/dunst";
            always = false;
            notification = false;
          }
          {
            command = "i3-msg workspace number 1";
            always = false;
            notification = false;
          }
          {
            command = "${pkgs.i3-auto-layout}/bin/i3-auto-layout";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.picom}/bin/picom -b";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.hsetroot}/bin/hsetroot -solid '#282828'";
            always = true;
            notification = false;
          }
        ];

        # Key bindings
        keybindings = let
          modifier = "Mod4";
        in {
          # Launch applications
          "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
          "${modifier}+Shift+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show run";
          "${modifier}+Return" = "exec --no-startup-id ${pkgs.ghostty}/bin/ghostty";

          # Window management
          "${modifier}+Shift+q" = "kill";
          "${modifier}+f" = "fullscreen toggle";

          # Focus
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Move windows
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Split orientation
          "${modifier}+m" = "split h";
          "${modifier}+v" = "split v";

          # Layouts
          "${modifier}+e" = "layout toggle split";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+a" = "focus parent";

          # Workspaces
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

          # Move to workspaces
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

          # System
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
          "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'";

          # Resize mode
          "${modifier}+r" = "mode resize";

          # Audio controls
          "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          # Media controls
          "XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioStop" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl stop";

          # Screenshots
          "Shift+XF86Tools" = "exec --no-startup-id ${pkgs.ksnip}/bin/ksnip --rectarea";
          "XF86Tools" = "exec --no-startup-id ${pkgs.ksnip}/bin/ksnip --fullscreen";

          # Screen lock
          "${modifier}+x" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock -c 000000";
        };

        # Modes
        modes = {
          resize = {
            "j" = "resize shrink width 10 px or 10 ppt";
            "k" = "resize grow height 10 px or 10 ppt";
            "l" = "resize shrink height 10 px or 10 ppt";
            "semicolon" = "resize grow width 10 px or 10 ppt";
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";
            "Return" = "mode default";
            "Escape" = "mode default";
            "${config.xsession.windowManager.i3.config.modifier}+r" = "mode default";
          };
        };

        # i3status-rust for status bar
        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
          }
        ];

        # Window settings
        window = {
          border = 2;
          titlebar = false;
          hideEdgeBorders = "smart";
        };

        # Floating modifier
        floating = {
          modifier = "Mod4";
        };

        # Workspace settings
        workspaceAutoBackAndForth = true;

        colors = {
          focused = {
            border = "#4c7899";
            background = "#285577";
            text = "#ffffff";
            indicator = "#2e9ef4";
            childBorder = "#285577";
          };
          focusedInactive = {
            border = "#333333";
            background = "#5f676a";
            text = "#ffffff";
            indicator = "#484e50";
            childBorder = "#5f676a";
          };
          unfocused = {
            border = "#333333";
            background = "#222222";
            text = "#888888";
            indicator = "#292d2e";
            childBorder = "#222222";
          };
        };
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          blocks = [
            {
              block = "disk_space";
              path = "/";
              info_type = "available";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "memory";
              format = " $icon $mem_used_percents ";
              format_alt = " $icon $swap_used_percents ";
            }
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "load";
              interval = 1;
              format = " $icon $1m ";
            }
            {
              block = "sound";
            }
            {
              block = "net";
              format = " $icon {$signal_strength $ssid $frequency|Wired connection} ";
              format_alt = " $icon {$signal_strength $ssid $frequency|Wired connection} via $device ";
            }
            {
              block = "time";
              interval = 60;
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
          settings = {
            theme = {
              theme = "gruvbox-dark";
            };
            icons = {
              icons = "awesome4";
            };
          };
        };
      };
    };
  };
}