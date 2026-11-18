{ ... }:
{
  flake.modules.nixos.nuc-media =
    { lib, ... }:
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
        uid = lib.mkForce 1002;
        extraGroups = [ "dataaccess" ];
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
