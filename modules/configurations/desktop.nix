{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
  username = config.flake.meta.owner.username;
in
{
  configurations.nixos.desktop.module = {
    imports = with nixos; [
      base
      desktop
      desktop-hw
      desktop-services
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    services.my.borgbackup = {
      enable = true;
      excludePaths = [
        "/home/${username}/.bitcoin/blocks/*"
        "/home/${username}/.bitcoin/chainstate/*"
        "/home/${username}/.bitcoin/indexes/*"
        "/home/${username}/src/**/.direnv/*"
        "/home/${username}/src/**/build/*"
        "/home/${username}/src/**/node_modules/*"
        "/home/${username}/src/**/target/*"
      ];
    };

    services.bgt = {
      autoAttest = true;
      enable = true;
      user = username;
    };

    services.journald.extraConfig = ''
      SystemMaxUse=2G
      MaxRetentionSec=1month
    '';

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
