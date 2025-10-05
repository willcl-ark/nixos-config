{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.host;
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/borg.nix
    ../../modules/bgt-watch.nix
  ];

  # Host-specific config based on host params
  boot.loader = mkMerge [
    (mkIf (cfg.bootLoader.type == "systemd-boot") {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    })
  ];

  boot.supportedFilesystems = [ "fuse.sshfs" ];

  environment.systemPackages = with pkgs; [
    apcupsd
    guix
    pwvucontrol
    sshfs
  ];

  programs.fuse.userAllowOther = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 10d --keep 10";
    flake = "/home/will/src/nixos-config";
  };

  hardware = {
    bluetooth.enable = true;
    acpilight.enable = true;
  };

  networking.hostName = cfg.name;

  services = {
    apcupsd.enable = true;
    printing = mkIf cfg.services.printing {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    guix.enable = true;

    my.borgbackup = {
      enable = true;
      excludePaths = [
        # Standard excludes are inherited from the module
        # Host-specific excludes:
        "/home/${cfg.user}/.bitcoin/blocks/*"
        "/home/${cfg.user}/.bitcoin/chainstate/*"
        "/home/${cfg.user}/.bitcoin/indexes/*"
      ];
    };

    bgt = {
      enable = true;
      user = cfg.user;
    };
  };

  virtualization.my = {
    enablePodman = lib.mkForce false;
    enableDocker = true;
    enableQemuUserEmulation = true;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/seedbox 0755 ${cfg.user} users - -"
  ];

  systemd.mounts = [
    {
      type = "fuse.sshfs";
      what = "davidblaine@100.95.152.4:/home/davidblaine/";
      where = "/mnt/seedbox";
      options = "identityfile=/home/${cfg.user}/.ssh/hetzner-temp,port=4747,idmap=user,allow_other,_netdev,reconnect,ServerAliveInterval=15";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      where = "/mnt/seedbox";
      automountConfig = {
        TimeoutIdleSec = "300";
      };
    }
  ];
}
