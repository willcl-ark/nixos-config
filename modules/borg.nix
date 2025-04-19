{ config, pkgs, self, ... }:

let
  backupPath = "/media/crucial1";
in
{
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
    after = [ "network.target" "local-fs.target" ];
    wants = [ "network.target" ];
    script = ''
      export BORG_PASSPHRASE=$(cat ${config.sops.secrets.borg_passphrase.path})
      export BORG_REPO=${backupPath}/backup-nixos

      ${pkgs.borgbackup}/bin/borg create \
        --filter AME \
        --show-rc \
        --compression lz4 \
        --exclude-caches \
        --exclude '/home/*/.cache/*' \
        --exclude '/home/*/.ccache/*' \
        --exclude '/home/will/.bitcoin/blocks/*' \
        --exclude '/home/will/.bitcoin/chainstate/*' \
        --exclude '/home/will/.bitcoin/indexes/*' \
        --exclude '/var/tmp/*' \
        --exclude '/var/cache/*' \
        --exclude '/var/log/journal/*' \
        --exclude '/nix/*' \
        ::'{hostname}-{now}' \
        /home \
        /etc/nixos \
        /root \
        /var/lib \
        /var/log

      ${pkgs.borgbackup}/bin/borg prune \
        --list \
        --show-rc \
        --keep-hourly 5 \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 1 \
        --keep-yearly 1 \
        --glob-archives='{hostname}-*'

      ${pkgs.borgbackup}/bin/borg compact
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };
  };

  systemd.timers.borgbackup = {
    description = "Run BorgBackup Every 3 Hours";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar="*-*-* 0/03:00:00";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };

}
