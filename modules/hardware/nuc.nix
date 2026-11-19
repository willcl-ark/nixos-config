{ inputs, ... }:
{
  flake.modules.nixos.nuc-hardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.disko.nixosModules.disko
      ];
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "uas"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-intel" ];
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.graphics.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 3;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";

      # Only the internal NVMe belongs in Disko. External storage is mount-only.
      disko.devices.disk.internal = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S467NX0KC41140T";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/802dcc1e-ab0b-4b37-b404-9ca49eb037f7";
        fsType = "ext4";
        options = [ "nofail" ];
      };
      fileSystems."/data" = {
        device = "10.0.0.130:/shared";
        fsType = "nfs";
        options = [
          "_netdev"
          "nofail"
          "x-systemd.automount"
          "x-systemd.mount-timeout=30s"
          "vers=3"
          "noatime"
        ];
      };
      swapDevices = [
        {
          device = "/swapfile";
          size = 32768;
        }
      ];
    };
}
