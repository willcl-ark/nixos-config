{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.host;
in {
  imports = [
    ../../modules/common.nix
    ../../modules/borg.nix
  ];

  # Host-specific config based on host params
  boot.loader = mkMerge [
    (mkIf (cfg.bootLoader.type == "systemd-boot") {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    })
  ];

  environment.systemPackages = with pkgs; [
    apcupsd
    guix
    pwvucontrol
    sshfs
  ];

  programs.fuse.userAllowOther = true;

  hardware = {
    bluetooth.enable = true;
    acpilight.enable = true;
  };

  networking.hostName = cfg.name;

  services = {
    apcupsd.enable = true;
    printing = mkIf cfg.services.printing {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.cups-brother-hll3230cdw];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    guix.enable = true;

    # Enable Borg backup with host-specific configuration
    my.borgbackup = {
      enable = true;
      # Only specify host-specific excludes
      excludePaths = [
        # Standard excludes are inherited from the module
        # Host-specific excludes:
        "/home/${cfg.user}/.bitcoin/blocks/*"
        "/home/${cfg.user}/.bitcoin/chainstate/*"
        "/home/${cfg.user}/.bitcoin/indexes/*"
      ];
    };
  };
  systemd.tmpfiles.rules = [
    "d /mnt/seedbox 0755 ${cfg.user} users - -"
  ];
  fileSystems."/mnt/seedbox" = {
    device = "davidblaine@100.95.152.4:/home/davidblaine/";
    fsType = "sshfs";
    options = [
      "IdentityFile=/home/${cfg.user}/.ssh/hetzner-temp"
      "port=4747"
      "allow_other"
    ];
  };
}
