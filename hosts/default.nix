{ lib, ... }:

with lib;

{
  # host options that can be used across the configuration
  options.host = {
    name = mkOption {
      type = types.str;
      description = "The hostname of the machine";
    };

    user = mkOption {
      type = types.str;
      default = "will";
      description = "The primary user";
    };

    cpu = {
      type = mkOption {
        type = types.enum [ "intel" "amd" "generic" ];
        default = "generic";
        description = "The CPU type for microcode and optimizations";
      };

      cores = mkOption {
        type = types.int;
        default = 16;
        description = "Number of CPU cores";
      };
    };

    gpu = {
      type = mkOption {
        type = types.enum [ "nvidia" "amd" "intel" "none" ];
        default = "none";
        description = "The GPU type for drivers and configurations";
      };
    };

    filesystem = {
      type = mkOption {
        type = types.enum [ "ext4" "btrfs" "zfs" "other" ];
        default = "ext4";
        description = "Main filesystem used";
      };
    };

    isLaptop = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this machine is a laptop (enables power management, etc.)";
    };

    isDesktop = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this machine is a desktop";
    };

    isVM = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this machine is a virtual machine";
    };

    bootLoader = {
      type = mkOption {
        type = types.enum [ "systemd-boot" "grub-efi" "grub-bios" ];
        default = "systemd-boot";
        description = "Boot loader to use";
      };
    };

    services = {
      ssh = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSH server";
      };

      tailscale = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Tailscale";
      };

      printing = mkOption {
        type = types.bool;
        default = false;
        description = "Enable printing services";
      };
    };
  };
}
