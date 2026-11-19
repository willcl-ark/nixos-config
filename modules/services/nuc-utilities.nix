{ ... }:
{
  flake.modules.nixos.nuc-utilities =
    { pkgs, ... }:
    {
      services.apcupsd = {
        enable = true;
        # Keep the existing shutdown thresholds; the native module supplies
        # apccontrol and the final shutdown-stage UPS power-off service.
        configText = ''
          UPSNAME homeups
          UPSCABLE usb
          UPSTYPE usb
          LOCKFILE /run/lock
          PWRFAILDIR /run/apcupsd
          NOLOGINDIR /run
          ONBATTERYDELAY 6
          BATTERYLEVEL 5
          MINUTES 5
          TIMEOUT 0
          ANNOY 300
          ANNOYDELAY 60
          NOLOGON disable
          KILLDELAY 0
          NETSERVER on
          NISIP 127.0.0.1
          NISPORT 3551
          EVENTSFILE /var/log/apcupsd.events
          EVENTSFILEMAX 10
          UPSCLASS standalone
          UPSMODE disable
          STATTIME 0
          STATFILE /var/log/apcupsd.status
          LOGSTATS off
          DATATIME 0
        '';
      };
      # Keep the powerfail marker after the daemon stops, until the native
      # apcupsd-killpower unit runs at the end of shutdown.
      systemd.services.apcupsd.serviceConfig.RuntimeDirectoryPreserve = "yes";

      # Preserve the existing static NZBGet 21.1 installation and runtime config.
      # The pinned Nix package is 26.3: upgrading it is a separate migration.
      # AppDir also contains the web UI, CA bundle, scripts and unpacking tools.
      systemd.services.nzbget = {
        description = "NZBGet Daemon";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        unitConfig.RequiresMountsFor = [
          "/home/will/nzbget"
          "/data"
        ];
        path = [ pkgs.python3 ];
        serviceConfig = {
          Type = "simple";
          User = "plex";
          Group = "plex";
          UMask = "0002";
          ExecStart = "/home/will/nzbget/nzbget --server --configfile /home/will/nzbget/nzbget.conf --option OutputMode=loggable";
          ExecStop = "/home/will/nzbget/nzbget --configfile /home/will/nzbget/nzbget.conf --quit";
          Restart = "on-failure";
        };
      };
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6789 ];
    };
}
