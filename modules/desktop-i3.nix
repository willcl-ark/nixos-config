{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host.desktop;
in {
  config = mkIf (cfg.enable && cfg.environment == "i3") {
    environment = {
      pathsToLink = ["/libexec"];
      systemPackages = with pkgs; [
        hsetroot
        i3-auto-layout
        i3status-rust
        ksnip
        libsecret
        lxappearance
        lxqt.lxqt-policykit
        networkmanagerapplet
        picom
        playerctl
        rofi
      ];
    };

    programs.dconf.enable = true;

    security.pam.services.lightdm.enableGnomeKeyring = true;

    services = {
      gnome.gnome-keyring.enable = true;
      xserver = {
        enable = true;
        # DPI settings for 200% scaling
        dpi = 192; # 96 * 2 = 192
        # Keyboard layout
        xkb = {
          layout = "gb";
          variant = "";
        };
        desktopManager = {
          xterm.enable = false;
        };
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            i3status
            i3lock
            i3blocks
          ];
        };
      };
      picom.enable = true;
      displayManager.defaultSession = "none+i3";
      # Mouse and touchpad settings
      libinput = {
        enable = true;
        mouse.naturalScrolling = true;
        touchpad.naturalScrolling = true;
      };
    };
  };
}
