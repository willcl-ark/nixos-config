{ config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.base =
    { ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "docker"
        ];
        hashedPassword = "$y$j9T$JV/cbQ/2QXvnouRK.3UPT0$9ZE12JKYtJPuQEfqHeEgl072NxE.VoTov2F/u7tyxD5";
      };

      documentation.man.generateCaches = false;
    };
}
