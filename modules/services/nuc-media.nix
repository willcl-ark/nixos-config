{ ... }:
{
  flake.modules.nixos.nuc-media =
    { lib, pkgs, ... }:
    {
      # Restore state before first start; these modules do not recreate databases.
      services.plex = {
        enable = true;
        dataDir = "/home/will/plex";
        openFirewall = false;
      };
      services.sonarr = {
        enable = true;
        dataDir = "/var/lib/sonarr";
        group = "media";
        openFirewall = false;
      };
      services.radarr = {
        enable = true;
        dataDir = "/var/lib/radarr";
        group = "media";
        openFirewall = false;
      };

      # Preserve ownership on existing local files and the NAS.
      users.users.plex = {
        uid = lib.mkForce 998;
        extraGroups = [
          "media"
          "dataaccess"
          "video"
          "render"
        ];
      };
      users.groups.plex.gid = lib.mkForce 998;
      users.users.sonarr = {
        uid = lib.mkForce 119;
        extraGroups = [ "dataaccess" ];
      };
      users.users.radarr = {
        isSystemUser = true;
        uid = lib.mkForce 1002;
        extraGroups = [ "dataaccess" ];
      };

      # The NAS parent was root:root 0770, blocking access to its media-owned
      # children. Repair the parent and grant service ACL access after mounting.
      systemd.services.nas-download-permissions = {
        description = "Set shared NAS download directory permissions";
        unitConfig.RequiresMountsFor = [ "/data" ];
        serviceConfig.Type = "oneshot";
        path = [
          pkgs.coreutils
          pkgs.acl
        ];
        script = ''
          chgrp media /data/downloads
          chmod 2770 /data/downloads
          # The NAS has existing ACLs; group/mode alone does not grant these users access.
          setfacl -m u:998:rwx,u:119:rwx /data/downloads /data/downloads/tv /data/downloads/movies
        '';
      };

      systemd.services.nzbget = {
        requires = [ "nas-download-permissions.service" ];
        after = [ "nas-download-permissions.service" ];
      };

      systemd.services.plex = {
        unitConfig.RequiresMountsFor = [
          "/home/will/plex"
          "/data"
        ];
        # Plex state is intentionally retained under /home.
        serviceConfig.ProtectHome = lib.mkForce false;
      };
      systemd.services.sonarr = {
        requires = [ "nas-download-permissions.service" ];
        after = [ "nas-download-permissions.service" ];
        unitConfig.RequiresMountsFor = [
          "/data"
          "/home/will/nzbget"
        ];
        serviceConfig = {
          # Existing download paths are under /home/will/nzbget.
          ProtectHome = lib.mkForce false;
          UMask = lib.mkForce "0002";
        };
      };
      systemd.services.radarr = {
        requires = [ "nas-download-permissions.service" ];
        after = [ "nas-download-permissions.service" ];
        unitConfig.RequiresMountsFor = [
          "/data"
          "/home/will/nzbget"
        ];
        serviceConfig = {
          ProtectHome = lib.mkForce false;
          UMask = lib.mkForce "0002";
        };
      };
    };
}
