{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.virtualization.my;
in {
  options.virtualization.my = {
    enablePodman = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Podman";
    };

    enableDocker = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Docker";
    };

    enableKvm = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable KVM virtualization";
    };

    enableQemuUserEmulation = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable QEMU user emulation for multi-architecture containers";
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.enableDocker && cfg.enablePodman);
          message = "Cannot enable both Docker and Podman simultaneously. Please disable one of them.";
        }
      ];
    }

    (mkIf cfg.enableDocker {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune.enable = true;
      };
      users.groups.docker = {};
      environment.systemPackages = with pkgs; [docker-compose];
    })

    (mkIf cfg.enablePodman {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      virtualisation.containers = {
        enable = true;
        storage.settings.storage = {
          driver = "overlay";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
      environment.systemPackages = with pkgs; [podman-compose];
    })

    (mkIf cfg.enableKvm {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          ovmf.enable = true;
        };
      };
      users.groups.libvirtd = {};
      environment.systemPackages = with pkgs; [virt-manager spice-gtk];
    })

    (mkIf cfg.enableQemuUserEmulation {
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "riscv64-linux"
        "s390x-linux"
      ];
      boot.binfmt.preferStaticEmulators = true; # https://github.com/NixOS/nixpkgs/pull/334859

      environment.systemPackages = with pkgs; [
        qemu
        qemu-utils
      ];
      virtualisation.containers.registries.search = ["docker.io"];
    })
  ];
}
