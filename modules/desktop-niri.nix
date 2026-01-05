{
  lib,
  pkgs,
  config,
  matugen,
  ...
}:
with lib;
{
  imports = [
    ./common.nix
    matugen.nixosModules.default
  ];

  console.keyMap = "uk";

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  security.rtkit.enable = true; # For pipewire

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

  environment.systemPackages = with pkgs; [
    ghostty
    nautilus
    mate.mate-polkit
    xwayland-satellite # For X11 apps support
    libsecret
    playerctl
    matugen.packages.${pkgs.stdenv.hostPlatform.system}.default # Material You color generation
  ];

  programs.niri = {
    enable = true;
  };
  programs.dconf.enable = true;

  # Matugen configuration for terminal color schemes
  programs.matugen = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true; # Prevents systemd messages from interrupting greeting
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Required portals for niri
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome # Required for screencasting
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  security = {
    pam.services.greetd.enableGnomeKeyring = true;
    polkit.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;

    # use libinput for Wayland
    libinput = {
      enable = true;
      mouse.naturalScrolling = true;
      touchpad.naturalScrolling = true;
    };

    # Disable X11 services since we're using Wayland
    xserver.enable = false;
  };

  # NVIDIA-specific configuration for niri
  # Based on niri documentation
  environment.etc."niri/niri-portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.Screencast=gnome
    org.freedesktop.impl.portal.Screenshot=gnome
  '';

  environment.sessionVariables = {
    # Qt theming
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";

    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";

    # Electron & Chromium
    NIXOS_OZONE_WL = "1";

    # NVIDIA-specific
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  home-manager.sharedModules =
    let
      homeDir = "/home/${config.host.user}";
    in
    [
      {
        programs.niri = {
          settings = {
            screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d %H-%M-%S.png";

            spawn-at-startup = [
              # DankMaterialShell integration
              {
                command = [
                  "bash"
                  "-c"
                  "wl-paste --watch cliphist store &"
                ];
              }
              { command = [ "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1" ]; }
              {
                command = [
                  "dms"
                  "run"
                ];
              }
            ];

            xwayland-satellite = {
              path = "xwayland-satellite";
            };

            outputs = {
              "DP-1" = {
                scale = 1.5;
              };
            };

            input = {
              keyboard = {
                xkb = {
                  layout = "gb";
                };
                numlock = true;
              };
              touchpad = {
                natural-scroll = true;
              };
              mouse = {
                natural-scroll = true;
              };
              workspace-auto-back-and-forth = true;
            };

            layout = {
              always-center-single-column = true;
              preset-column-widths = [
                { proportion = 0.33333; }
                { proportion = 0.5; }
                { proportion = 0.66667; }
                { proportion = 1.0; }
              ];
            };

            animations = {
              enable = false;
            };

            binds = {
              # Essential niri defaults
              "Mod+1".action.focus-workspace = 1;
              "Mod+2".action.focus-workspace = 2;
              "Mod+3".action.focus-workspace = 3;
              "Mod+4".action.focus-workspace = 4;
              "Mod+5".action.focus-workspace = 5;
              "Mod+6".action.focus-workspace = 6;
              "Mod+7".action.focus-workspace = 7;
              "Mod+8".action.focus-workspace = 8;
              "Mod+9".action.focus-workspace = 9;
              "Mod+0".action.focus-workspace = 10;

              "Mod+Shift+1".action.move-column-to-workspace = 1;
              "Mod+Shift+2".action.move-column-to-workspace = 2;
              "Mod+Shift+3".action.move-column-to-workspace = 3;
              "Mod+Shift+4".action.move-column-to-workspace = 4;
              "Mod+Shift+5".action.move-column-to-workspace = 5;
              "Mod+Shift+6".action.move-column-to-workspace = 6;
              "Mod+Shift+7".action.move-column-to-workspace = 7;
              "Mod+Shift+8".action.move-column-to-workspace = 8;
              "Mod+Shift+9".action.move-column-to-workspace = 9;
              "Mod+Shift+0".action.move-column-to-workspace = 10;

              "Mod+q".action.close-window = { };
              "Mod+a".action.focus-column-left = { };
              "Mod+d".action.focus-column-right = { };
              "Mod+s".action.focus-window-or-workspace-down = { };
              "Mod+w".action.focus-window-or-workspace-up = { };
              "Mod+Ctrl+h".action.move-column-left = { };
              "Mod+Ctrl+l".action.move-column-right = { };
              "Mod+Ctrl+j".action.move-window-down = { };
              "Mod+Ctrl+k".action.move-window-up = { };

              # Workspace navigation
              "Mod+u".action.focus-workspace-down = { };
              "Mod+Page_Down".action.focus-workspace-down = { };
              "Mod+i".action.focus-workspace-up = { };
              "Mod+Page_Up".action.focus-workspace-up = { };
              "Mod+Ctrl+u".action.move-column-to-workspace-down = { };
              "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
              "Mod+Ctrl+i".action.move-column-to-workspace-up = { };
              "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
              "Mod+Shift+u".action.move-workspace-down = { };
              "Mod+Shift+Page_Down".action.move-workspace-down = { };
              "Mod+Shift+i".action.move-workspace-up = { };
              "Mod+Shift+Page_Up".action.move-workspace-up = { };

              # Column manipulation - Note: Mod+comma overridden by DankMaterialShell settings
              # "Mod+comma".action.consume-window-into-column = {}; # Commented - DMS uses this
              "Mod+period".action.expel-window-from-column = { };
              "Mod+bracketleft".action.consume-or-expel-window-left = { };
              "Mod+bracketright".action.consume-or-expel-window-right = { };

              # Column and window resizing
              "Mod+r".action.switch-preset-column-width = { };
              "Mod+Shift+r".action.switch-preset-window-height = { };
              "Mod+f".action.maximize-column = { };
              "Mod+c".action.center-column = { };
              "Mod+minus".action.set-column-width = "-10%";
              "Mod+equal".action.set-column-width = "+10%";
              "Mod+Shift+minus".action.set-window-height = "-10%";
              "Mod+Shift+equal".action.set-window-height = "+10%";
              "Mod+Ctrl+r".action.reset-window-height = { };

              # Window state (DankMaterialShell overrides Mod+v)
              "Mod+Shift+f".action.fullscreen-window = { };
              "Mod+Shift+v".action.switch-layout = "next";

              # System
              "Mod+Shift+e".action.quit = { };
              "Ctrl+Alt+Delete".action.quit = { };
              "Mod+Shift+slash".action.show-hotkey-overlay = { };

              # Custom overrides
              "Mod+Return".action.spawn = "ghostty";
              "Print".action.screenshot-screen = { };
              "Shift+Print".action.screenshot = { };
              "Alt+Print".action.screenshot-window = { };
              "Ctrl+Print".action.screenshot-screen = { };

              # DankMaterialShell integration
              "Mod+Space".action.spawn = [
                "dms"
                "ipc"
                "call"
                "spotlight"
                "toggle"
              ];
              "Mod+v".action.spawn = [
                "dms"
                "ipc"
                "call"
                "clipboard"
                "toggle"
              ];
              "Mod+m".action.spawn = [
                "dms"
                "ipc"
                "call"
                "processlist"
                "toggle"
              ];
              "Mod+n".action.spawn = [
                "dms"
                "ipc"
                "call"
                "notifications"
                "toggle"
              ];
              "Mod+comma".action.spawn = [
                "dms"
                "ipc"
                "call"
                "settings"
                "toggle"
              ];
              "Mod+p".action.spawn = [
                "dms"
                "ipc"
                "call"
                "notepad"
                "toggle"
              ];
              # "Super+Alt+l".action.spawn = ["dms" "ipc" "call" "lock" "lock"];
              "Mod+x".action.spawn = [
                "bash"
                "-c"
                "dms ipc call lock lock; sleep 10; niri msg action power-off-monitors"
              ];
              "XF86AudioPlay".action.spawn = [
                "dms"
                "ipc"
                "call"
                "mpris"
                "playPause"
              ];
              "XF86AudioNext".action.spawn = [
                "dms"
                "ipc"
                "call"
                "mpris"
                "next"
              ];
              "XF86AudioPrev".action.spawn = [
                "dms"
                "ipc"
                "call"
                "mpris"
                "previous"
              ];
              "XF86AudioRaiseVolume".action.spawn = [
                "dms"
                "ipc"
                "call"
                "audio"
                "increment"
                "3"
              ];
              "XF86AudioLowerVolume".action.spawn = [
                "dms"
                "ipc"
                "call"
                "audio"
                "decrement"
                "3"
              ];
              "XF86AudioMute".action.spawn = [
                "dms"
                "ipc"
                "call"
                "audio"
                "mute"
              ];
              "XF86AudioMicMute".action.spawn = [
                "dms"
                "ipc"
                "call"
                "audio"
                "micmute"
              ];
              "XF86MonBrightnessUp".action.spawn = [
                "dms"
                "ipc"
                "call"
                "brightness"
                "increment"
                "5"
                ""
              ];
              "XF86MonBrightnessDown".action.spawn = [
                "dms"
                "ipc"
                "call"
                "brightness"
                "decrement"
                "5"
                ""
              ];
              "Mod+Shift+n".action.spawn = [
                "dms"
                "ipc"
                "call"
                "night"
                "toggle"
              ];

              # Custom scripts
              "Mod+g".action.spawn = [ "${homeDir}/.local/bin/gh-issue-open.sh" ];
            };

            window-rules = [
              { clip-to-geometry = true; }
              {
                matches = [
                  {
                    app-id = "com.mitchellh.ghostty";
                  }
                ];
                default-column-width = {
                  proportion = 0.5;
                };
              }
            ];
          };
        };
      }
    ];
}
