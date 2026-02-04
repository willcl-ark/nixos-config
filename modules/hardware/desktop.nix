{ ... }:
{
  flake.modules.nixos.desktop-hw =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/68fb9d8a-99ea-4937-9d04-2c824aac8f80";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/2285-DE71";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/media/crucial1" = {
        device = "/dev/disk/by-uuid/23172940-1b4f-44c1-9ed4-fabf7f3ad9ea";
        fsType = "ext4";
        options = [ "defaults" ];
      };

      fileSystems."/mnt/bulk" = {
        device = "/dev/disk/by-uuid/bf1c56b7-bc3e-4776-8155-0d943306ea1d";
        fsType = "ext4";
        options = [ "defaults" ];
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      networking.hostName = "nix-desktop";
    };
}
