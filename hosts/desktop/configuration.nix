{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.host;
in
{
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
    pavucontrol
    light
  ];

  hardware = {
    bluetooth.enable = true;
    acpilight.enable = true;
  };

  # Enable light for brightness control
  programs.light.enable = true;

  # Add user to video group for brightness control
  users.users.${cfg.user}.extraGroups = [ "video" ];

  networking.hostName = cfg.name;

  services = {
    apcupsd.enable = true;
    printing = mkIf cfg.services.printing {
      enable = true;
      drivers = [ pkgs.gutenprint ];
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
}
