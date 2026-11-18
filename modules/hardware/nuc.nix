{ ... }:
{
  flake.modules.nixos.nuc-hardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
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

      # Existing filesystems only. No partitioning or formatting is specified.
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/3413781e-3087-412c-9f4f-d7545545eb5a";
        fsType = "ext4";
      };
      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-uuid/2826-6B44";
        fsType = "vfat";
        options = [ "umask=0077" ];
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/7d084f95-464f-41af-88cd-a767980ce889";
        fsType = "ext4";
      };
      fileSystems."/var" = {
        device = "/dev/disk/by-uuid/ec514de2-ac1c-435b-8216-932624237842";
        fsType = "ext4";
      };
      fileSystems."/tmp" = {
        device = "/dev/disk/by-uuid/d6c51c1f-63df-4c9a-90f8-329815c276b2";
        fsType = "ext4";
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
          "vers=3"
          "noatime"
        ];
      };
      swapDevices = [
        { device = "/dev/disk/by-uuid/cd87cbf6-6f00-46a0-9c0f-47c203ba568d"; }
      ];
    };
}
