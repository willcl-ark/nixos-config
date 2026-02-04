{ ... }:
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune.enable = true;
      };

      users.groups.docker = { };

      virtualisation.containers = {
        enable = true;
        registries.search = [ "docker.io" ];
      };

      environment.systemPackages = [
        pkgs.docker-compose
        pkgs.qemu
        pkgs.qemu-utils
      ];

      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "riscv64-linux"
        "s390x-linux"
      ];
      boot.binfmt.preferStaticEmulators = true;
    };
}
