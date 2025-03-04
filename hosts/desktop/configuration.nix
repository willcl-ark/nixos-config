{ pkgs, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Boot configuration
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; # Use nodev instead of a specific device
      useOSProber = true;
      efiSupport = false;
      forceInstall = true;
    };
    # TODO: switch to UEFI
    # systemd-boot.enable = true;
    # efi.canTouchEfiVariables = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    curl
    git
    gnupg
    just
    pinentry-curses
    pinentry-gtk2 # For GUI PIN entry
    wget
    yubikey-manager
    yubikey-personalization
  ];

  # Better firmware handling
  hardware.enableAllFirmware = true;

  # Networking
  networking = {
    hostName = "nix-desktop";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 51820 ];
      allowPing = true;
    };
  };

  services = {
    # Printing
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    openssh.enable = true;

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client"; # Enable IP forwarding for relay nodes
    };

    # YubiKey support
    pcscd.enable = true; # Smart card daemon for Yubikey
    udev.packages = [ pkgs.yubikey-personalization pkgs.libu2f-host ];
  };

  time.timeZone = "Europe/London";

  # User account
  users.users.will = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme";
  };

  # Docker configuration
  virtualisation = {
    docker = {
      enable = true;
      # Rootless mode
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
      # Root mode
      daemon.settings = { storage-driver = "overlay2"; };
    };
  };

  system.stateVersion = "24.11";
}
