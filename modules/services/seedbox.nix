{ config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
    {
      programs.fuse.userAllowOther = true;
      environment.systemPackages = [ pkgs.sshfs ];

      systemd.tmpfiles.rules = [
        "d /mnt/seedbox 0755 ${username} users - -"
      ];

      systemd.mounts = [
        {
          type = "fuse.sshfs";
          what = "davidblaine@100.95.152.4:/home/davidblaine/";
          where = "/mnt/seedbox";
          options = "identityfile=/home/${username}/.ssh/hetzner-temp,port=4747,idmap=user,allow_other,_netdev,reconnect,ServerAliveInterval=15";
        }
      ];

      systemd.automounts = [
        {
          wantedBy = [ "multi-user.target" ];
          where = "/mnt/seedbox";
          automountConfig.TimeoutIdleSec = "300";
        }
      ];
    };
}
