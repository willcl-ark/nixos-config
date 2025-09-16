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
        nautilus
        networkmanagerapplet
        picom
        playerctl
        rofi
        udiskie
        xsel
      ];
    };

    programs.dconf.enable = true;
    programs.i3lock.enable = true;

    security.pam.services.lightdm.enableGnomeKeyring = true;

    ############### hydra ###################
    nix.buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 1;
      }
    ];
    nix.settings.allowed-uris = [
      "github:"
      "git+https://github.com/"
      "git+ssh://github.com/"
    ];
    nix.settings = {
      cores = 16;
      max-jobs = 1;
    };
    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [];
      useSubstitutes = true;
    };
    ############### hydra ###################

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
