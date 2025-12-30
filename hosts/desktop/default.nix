{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    # ../../modules/hydra.nix
    ./nvidia.nix
  ];

  host = {
    name = "nix-desktop";
    user = "will";
    cpu = {
      type = "intel";
      cores = 16;
    };
    gpu.type = "nvidia";
    filesystem.type = "ext4";
    isDesktop = true;
    bootLoader.type = "systemd-boot";
    services = {
      ssh = true;
      tailscale = true;
      printing = false;
    };
  };
}
