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
  };

  config = {
    virtualisation.libvirtd = mkIf cfg.enableKvm {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        ovmf.enable = true;
      };
    };

    virtualisation.podman = mkIf cfg.enablePodman {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Add users to necessary groups
    users.groups = mkMerge [
      (mkIf cfg.enableKvm {libvirtd = {};})
    ];

    # Add necessary packages
    environment.systemPackages = mkMerge [
      (mkIf cfg.enableKvm (with pkgs; [virt-manager spice-gtk]))
    ];
  };
}
