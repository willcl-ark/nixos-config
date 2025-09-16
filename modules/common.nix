{
  lib,
  pkgs,
  self,
  ...
}:
with lib; {
  imports = [
    ./networking.nix
    ./security.nix
    ./users.nix
    ./virtualization.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["will"];

  nixpkgs.config.allowUnfree = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    bat
    curl
    dig
    eza
    fd
    file
    fzf
    git
    htop
    imagemagick
    jq
    just
    magic-wormhole
    mosh
    ncdu
    self.inputs.ned.packages.${pkgs.stdenv.hostPlatform.system}.default
    nettools
    nfs-utils
    nh
    pinentry
    pinentry-curses
    pinentry-gnome3
    pinentry-tty
    ripgrep
    rsync
    sops
    stow
    time
    tree
    wget

    # Specialized tools
    bitcoind
    borgbackup
    btop
    cachix
    tor
  ];

  # Enable firmware for all devices
  hardware.enableAllFirmware = true;

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

  users.my = {
    defaultUser = "will";
    createDefaultUser = true;
    hashedPassword = "$y$j9T$JV/cbQ/2QXvnouRK.3UPT0$9ZE12JKYtJPuQEfqHeEgl072NxE.VoTov2F/u7tyxD5";
  };

  networking.my = {
    enableNetworkManager = true;
    enableFirewall = true;
    enableTailscale = true;
  };

  security.my = {
    enableYubikey = true;
    enableKeyd = true;
    remapCapsToEsc = true;
    gpg.enable = true;
  };

  virtualization.my = {
    enablePodman = true;
  };

  # (do not change after deployment)
  system.stateVersion = "25.05";
}
