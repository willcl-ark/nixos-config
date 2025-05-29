{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
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
    desktop = {
      enable = true;
      environment = "i3"; # Change this to "gnome" to switch to GNOME
    };
    services = {
      ssh = true;
      tailscale = true;
      printing = true;
    };
  };
}
