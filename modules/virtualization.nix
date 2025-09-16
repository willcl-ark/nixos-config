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
      # Enable binfmt emulation for multiple architectures
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "riscv64-linux"
      ];

      # Install QEMU user emulation packages
      environment.systemPackages = with pkgs; [
        qemu
        qemu-utils
      ];

      # Enable container runtime to use QEMU for cross-platform builds
      virtualisation.containers.registries.search = ["docker.io"];
    })
  ];
}
