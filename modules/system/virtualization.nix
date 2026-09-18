{ ... }:
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
      };

      virtualisation.containers = {
        enable = true;
        registries.settings.unqualified-search-registries = [ "docker.io" ];
      };

      environment.systemPackages = [
        pkgs.podman-compose
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
