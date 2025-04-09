{ pkgs, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    curl
    eza
    fd
    fzf
    git
    gnupg
    htop
    jq
    just
    magic-wormhole
    mosh
    neovim
    ncdu
    nettools
    nfs-utils
    pinentry-curses
    pinentry-gtk2 # For GUI PIN entry
    ripgrep
    rsync
    time
    tor
    wget
    yubikey-manager
    yubikey-personalization
  ];

  programs.fish.enable = true; # Enables vendor fish completions

  hardware.enableAllFirmware = true;

  # Networking base config
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # ssh
      allowedUDPPorts = [ 51820 ]; # wireguard
      allowPing = true;
    };
  };

  services = {
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

    displayManager.defaultSession = "sway";

    xserver.xkb.options = "caps:escape";
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
      # Rootless mode
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
      # Root mode
      daemon.settings = { storage-driver = "overlay2"; };
    };
  };

  system.stateVersion = "25.05";
}
