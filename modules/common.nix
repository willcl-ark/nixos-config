{ pkgs, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    bat
    borgbackup
    curl
    eza
    fd
    fzf
    git
    gnupg
    htop
    jq
    just
    keyd
    magic-wormhole
    mosh
    ncdu
    neovim
    nettools
    nfs-utils
    pinentry
    pinentry-curses
    pinentry-gnome3
    pinentry-tty
    ripgrep
    rsync
    time
    tor
    wget
    yubikey-manager
    yubikey-personalization
  ];

  programs.fish.enable = true; # Enables vendor fish completions
  documentation.man.generateCaches = false; # Disable very slow man-cache build

  hardware.enableAllFirmware = true;

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = true;
    };
  };

  services = {
    openssh.enable = true;

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client"; # Enable IP forwarding for relay nodes
    };

    # YubiKey support
    pcscd.enable = true; # Smart card daemon for Yubikey
    udev.packages = [ pkgs.yubikey-personalization pkgs.libu2f-host ];

    # Remap caps lock to escape
    keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ]; # Apply to all keyboards
          settings = {
            main = {
              "capslock" = "esc"; # Remap Caps Lock to Escape
            };
          };
        };
      };
    };

  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  users.users.will = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    hashedPassword = "$y$j9T$JV/cbQ/2QXvnouRK.3UPT0$9ZE12JKYtJPuQEfqHeEgl072NxE.VoTov2F/u7tyxD5";
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  system.stateVersion = "25.05";
}
