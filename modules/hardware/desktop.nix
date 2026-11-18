{ ... }:
{
  flake.modules.nixos.desktop-hw =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    let
      # Pump duty (0-255) by liquid temperature: 60% up to 30°C, rising linearly to 100% at 40°C.
      pumpDutyAt =
        liquidTemp:
        if liquidTemp <= 30 then
          153
        else if liquidTemp >= 40 then
          255
        else
          153 + (liquidTemp - 30) * 102 / 10;
      # The nzxt-kraken3 driver exposes 40 curve points covering 20°C to 59°C.
      pumpCurveAttrs = lib.concatMapStrings (
        point: ''ATTR{temp1_auto_point${toString point}_pwm}="${toString (pumpDutyAt (19 + point))}", ''
      ) (lib.range 1 40);
    in
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

      # Apply the Kraken pump curve on boot and USB reconnection.
      # Write the curve points before switching to curve control (pwm1_enable=2).
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="x53", ${pumpCurveAttrs}ATTR{pwm1_enable}="2"
      '';

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
      fileSystems."/mnt/nvme0" = {
        device = "/dev/disk/by-uuid/0a0a6df9-bb5e-45ae-818c-e7d6716ceeb7";
        fsType = "ext4";
        options = [ "defaults" ];
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      networking.hostName = "nix-desktop";
    };
}
