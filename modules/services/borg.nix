{ inputs, config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.desktop-services =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.my.borgbackup;
    in
    {
      options.services.my.borgbackup = {
        enable = lib.mkEnableOption "BorgBackup service";
        backupPath = lib.mkOption {
          type = lib.types.str;
          default = "/media/crucial1";
        };
        repoName = lib.mkOption {
          type = lib.types.str;
          default = "backup-nixos";
        };
        compression = lib.mkOption {
          type = lib.types.str;
          default = "lz4";
        };
        schedule.onCalendar = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "*-*-* 09:00:00"
            "*-*-* 12:00:00"
            "*-*-* 15:00:00"
            "*-*-* 18:00:00"
            "*-*-* 22:00:00"
          ];
        };
        schedule.randomDelay = lib.mkOption {
          type = lib.types.str;
          default = "10m";
        };
        retention = {
          hourly = lib.mkOption {
            type = lib.types.int;
            default = 5;
          };
          daily = lib.mkOption {
            type = lib.types.int;
            default = 7;
          };
          weekly = lib.mkOption {
            type = lib.types.int;
            default = 4;
          };
          monthly = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
          yearly = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
        };
        excludePaths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/home/*/.cache/*"
            "/home/*/.cargo/registry/cache/*"
            "/home/*/.ccache/*"
            "/home/*/.local/share/containers/*"
            "/home/*/.rustup/toolchains/*"
            "/nix/*"
            "/var/cache/*"
            "/var/log/journal/*"
            "/var/tmp/*"
          ];
        };
        includePaths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/home"
            "/etc/nixos"
            "/root"
            "/var/lib"
            "/var/log"
          ];
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          sops
          borgbackup
          gnupg
          yubikey-personalization
          pcsclite
          ssh-to-age
        ];
        services.pcscd.enable = true;
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
        sops = {
          defaultSopsFile = "${inputs.self}/secrets/default.yaml";
          secrets.borg_passphrase = {
            mode = "0600";
            owner = "root";
            group = "root";
          };
        };
        systemd.services.borgbackup = {
          description = "BorgBackup Service";
          after = [
            "network.target"
            "local-fs.target"
          ];
          wants = [ "network.target" ];
          script =
            let
              borgCmd = "${pkgs.borgbackup}/bin/borg";
              excludeArgs = lib.concatMapStrings (path: "--exclude '${path}' \\\n        ") cfg.excludePaths;
              includeArgs = lib.concatStringsSep " " cfg.includePaths;
            in
            ''
              export BORG_PASSPHRASE=$(cat ${config.sops.secrets.borg_passphrase.path})
              export BORG_REPO=${cfg.backupPath}/${cfg.repoName}

              ${borgCmd} create \
                --filter AME \
                --show-rc \
                --compression ${cfg.compression} \
                --exclude-caches \
                ${excludeArgs}::'{hostname}-{now}' \
                ${includeArgs}

              ${borgCmd} prune \
                --list \
                --show-rc \
                --keep-hourly ${toString cfg.retention.hourly} \
                --keep-daily ${toString cfg.retention.daily} \
                --keep-weekly ${toString cfg.retention.weekly} \
                --keep-monthly ${toString cfg.retention.monthly} \
                --keep-yearly ${toString cfg.retention.yearly} \
                --glob-archives='{hostname}-*'

              ${borgCmd} compact
            '';
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            Group = "root";
          };
        };
        systemd.timers.borgbackup = {
          description = "Run BorgBackup at scheduled times";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.schedule.onCalendar;
            Persistent = false;
            RandomizedDelaySec = cfg.schedule.randomDelay;
          };
        };
      };
    };
}
