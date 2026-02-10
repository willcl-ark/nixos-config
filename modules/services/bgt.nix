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
      cfg = config.services.bgt;
    in
    {
      options.services.bgt = {
        enable = lib.mkEnableOption "BGT watcher service for automated Bitcoin Core builds";
        user = lib.mkOption {
          type = lib.types.str;
          default = "will";
        };
        autoAttest = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        extraFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets.github_bgt_token = {
          sopsFile = "${inputs.self}/secrets/will.yaml";
          owner = cfg.user;
          mode = "0400";
        };

        systemd.user.services.bgt = {
          description = "BGT watcher daemon for automated Bitcoin Core builds";
          after = [
            "network-online.target"
            "gpg-agent.service"
          ];
          wants = [ "network-online.target" ];
          wantedBy = [ "default.target" ];
          environment = {
            HOME = "/home/${cfg.user}";
            GNUPGHOME = "/home/${cfg.user}/.gnupg";
            SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
            GIT_SSH_COMMAND = "ssh -F /home/${cfg.user}/.ssh/config";
          };
          path = with pkgs; [
            bash
            coreutils
            getent
            gnupg
            git
            gnumake
            guix
            openssh
          ];
          serviceConfig = {
            Type = "simple";
            ExecStart =
              let
                flags = [ ] ++ lib.optional cfg.autoAttest "--auto" ++ cfg.extraFlags;
              in
              "${pkgs.bash}/bin/bash -c 'export GITHUB_BGT_TOKEN=$(cat ${config.sops.secrets.github_bgt_token.path}) && /home/${cfg.user}/.cargo/bin/bgt watch start ${lib.concatStringsSep " " flags}'";
            Restart = "on-failure";
            RestartSec = "30s";
            StandardOutput = "journal";
            StandardError = "journal";
            ReadWritePaths = [
              "/home/${cfg.user}/.local/state/guix-builds"
              "/home/${cfg.user}/.config/bgt"
              "/home/${cfg.user}/.gnupg"
              "/run/secrets"
              "/run/user/1000/gnupg/"
            ];
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = "read-only";
            NoNewPrivileges = true;
          };
        };
      };
    };
}
