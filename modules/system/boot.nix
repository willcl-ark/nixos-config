{ inputs, ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      imports = [ inputs.bootvine.nixosModules.default ];

      services.bootvine.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.supportedFilesystems = [ "fuse.sshfs" ];
    };
}
