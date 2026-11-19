{ ... }:
{
  flake.modules.nixos.nuc-bitcoin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.bitcoind
        pkgs.electrs
      ];

      services.tor = {
        enable = true;
        client.enable = true;
        settings = {
          ControlPort = [
            {
              addr = "127.0.0.1";
              port = 9051;
            }
          ];
          CookieAuthentication = true;
          CookieAuthFile = "/run/tor/control.authcookie";
          CookieAuthFileGroupReadable = true;
        };
        relay.onionServices.bitcoind = {
          # Restore the existing onion keys; do not generate a new identity.
          path = "/var/lib/tor/bitcoind";
          map = [
            {
              port = 8333;
              target = {
                addr = "127.0.0.1";
                port = 8334;
              };
            }
          ];
        };
      };
      # Keep ownership of the existing Tor state while using NixOS's account name.
      users.users.tor.uid = lib.mkForce 117;
      users.groups.tor.gid = lib.mkForce 123;
      users.users.bitcoin.extraGroups = [ "tor" ];
      systemd.services.tor.unitConfig.AssertPathExists = "/var/lib/tor/bitcoind/hs_ed25519_secret_key";

      systemd.services.bitcoind = {
        description = "Bitcoin Core";
        wantedBy = [ "multi-user.target" ];
        requires = [ "tailscaled-autoconnect.service" ];
        wants = [ "tor.service" ];
        after = [
          "tailscaled-autoconnect.service"
          "tor.service"
        ];
        unitConfig.RequiresMountsFor = [
          "/home/bitcoin/.bitcoin"
          "/mnt/data/bitcoin/.bitcoin"
        ];
        # bitcoin.conf binds RPC to this address. A fresh Tailscale identity must
        # not silently change the RPC endpoint expected by existing clients.
        preStart = ''
          ${pkgs.iproute2}/bin/ip -4 address show dev tailscale0 |
            ${pkgs.gnugrep}/bin/grep -Fq 'inet 100.104.49.27/'
        '';
        serviceConfig = {
          User = "bitcoin";
          Group = "bitcoin";
          Type = "simple";
          # Preserve the private runtime config, including whitebind, RPC auth,
          # indexes, blocksdir and maxuploadtarget=500M. Never copy it to /nix/store.
          ExecStart = "${pkgs.bitcoind}/bin/bitcoind -daemon=0 -pid=/run/bitcoind/bitcoind.pid -conf=/home/bitcoin/.bitcoin/bitcoin.conf -datadir=/home/bitcoin/.bitcoin";
          RuntimeDirectory = "bitcoind";
          RuntimeDirectoryMode = "0710";
          Restart = "on-failure";
          RestartSec = 10;
          TimeoutStopSec = 600;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "full";
          NoNewPrivileges = true;
          MemoryDenyWriteExecute = true;
        };
      };

      systemd.services.electrs = {
        description = "Electrs";
        wantedBy = [ "multi-user.target" ];
        requires = [ "bitcoind.service" ];
        after = [ "bitcoind.service" ];
        unitConfig.RequiresMountsFor = [ "/home/bitcoin/electrs" ];
        environment.RUST_BACKTRACE = "1";
        serviceConfig = {
          User = "bitcoin";
          Group = "bitcoin";
          WorkingDirectory = "/home/bitcoin/electrs";
          # Live Debian uses 0.12.1; the flake pin currently supplies 0.12.0.
          # Confirm index compatibility before deployment; use nixpkgs as requested.
          ExecStart = "${pkgs.electrs}/bin/electrs --skip-default-conf-files --log-filters INFO --network bitcoin --db-dir /home/bitcoin/electrs/db-v0.12 --daemon-dir /home/bitcoin/.bitcoin --daemon-rpc-addr 127.0.0.1:8332 --electrum-rpc-addr 127.0.0.1:50001";
          Restart = "always";
          RestartSec = 60;
          TimeoutStopSec = 600;
          PrivateTmp = true;
          ProtectSystem = "full";
          NoNewPrivileges = true;
          MemoryDenyWriteExecute = true;
        };
      };

      systemd.services.electrum-tailscale = {
        description = "Tailnet-only Electrum TCP and TLS endpoints";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "tailscaled-autoconnect.service"
          "electrs.service"
        ];
        after = [
          "tailscaled-autoconnect.service"
          "electrs.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${config.services.tailscale.package}/bin/tailscale serve --bg --tcp=50001 tcp://127.0.0.1:50001
          ${config.services.tailscale.package}/bin/tailscale serve --bg --tls-terminated-tcp=50002 tcp://127.0.0.1:50001
        '';
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
        8332
        8333
        9333
        29000
        50001
        50002
      ];
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -i eno1 -s 10.0.0.0/8 -p tcp --dport 9333 -j nixos-fw-accept
      '';
      networking.firewall.extraStopCommands = ''
        iptables -D nixos-fw -i eno1 -s 10.0.0.0/8 -p tcp --dport 9333 -j nixos-fw-accept || true
      '';

      systemd.tmpfiles.rules = [
        "d /home/bitcoin/.bitcoin/log_old 0750 bitcoin bitcoin -"
      ];
      # The existing debug log and rotated files are under /home.
      systemd.services.logrotate.serviceConfig.ProtectHome = lib.mkForce false;
      services.logrotate.settings.bitcoin-debug = {
        files = [ "/home/bitcoin/.bitcoin/debug.log" ];
        su = "bitcoin bitcoin";
        frequency = "daily";
        rotate = 60;
        olddir = "/home/bitcoin/.bitcoin/log_old";
        maxsize = "1000M";
        missingok = true;
        notifempty = true;
        create = "640 bitcoin bitcoin";
        compress = true;
        delaycompress = true;
        sharedscripts = true;
        postrotate = ''
          if ${pkgs.systemd}/bin/systemctl is-active --quiet bitcoind.service; then
            ${pkgs.systemd}/bin/systemctl kill --kill-whom=main --signal=HUP bitcoind.service
          fi
        '';
      };
    };
}
