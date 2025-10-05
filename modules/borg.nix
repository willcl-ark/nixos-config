{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib;
let
  cfg = config.services.my.borgbackup;
in
{
  options.services.my.borgbackup = {
    enable = mkEnableOption "BorgBackup service";

    backupPath = mkOption {
      type = types.str;
      default = "/media/crucial1";
      description = "Path to backup destination";
    };

    repoName = mkOption {
      type = types.str;
      default = "backup-nixos";
      description = "Name of the Borg repository";
    };

    compression = mkOption {
      type = types.str;
      default = "lz4";
      example = "zstd";
      description = "Compression algorithm to use";
    };

    schedule = {
      hourly = mkOption {
        type = types.int;
        default = 3;
        description = "Run backup every X hours";
      };

      randomDelay = mkOption {
        type = types.str;
        default = "10m";
        description = "Random delay for backup start";
      };
    };

    retention = {
      hourly = mkOption {
        type = types.int;
        default = 5;
        description = "Number of hourly backups to keep";
      };

      daily = mkOption {
        type = types.int;
        default = 7;
        description = "Number of daily backups to keep";
      };

      weekly = mkOption {
        type = types.int;
        default = 4;
        description = "Number of weekly backups to keep";
      };

      monthly = mkOption {
        type = types.int;
        default = 1;
        description = "Number of monthly backups to keep";
      };

      yearly = mkOption {
        type = types.int;
        default = 1;
        description = "Number of yearly backups to keep";
      };
    };

    excludePaths = mkOption {
      type = types.listOf types.str;
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
      description = "Paths to exclude from backup";
    };

    includePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "/home"
        "/etc/nixos"
        "/root"
        "/var/lib"
        "/var/log"
      ];
      description = "Paths to include in backup";
    };
  };

  config = mkIf cfg.enable {
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
      defaultSopsFile = "${self}/secrets/default.yaml";
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
          excludeArgs = concatMapStrings (path: "--exclude '${path}' \\\n        ") cfg.excludePaths;
          includeArgs = concatStringsSep " " cfg.includePaths;
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
      description = "Run BorgBackup Every ${toString cfg.schedule.hourly} Hours";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 0/${toString cfg.schedule.hourly}:00:00";
        Persistent = true;
        RandomizedDelaySec = cfg.schedule.randomDelay;
      };
    };
  };
}
