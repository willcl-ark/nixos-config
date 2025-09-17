{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.bgt;
in {
  options.services.bgt = {
    enable = mkEnableOption "BGT watcher service for automated Bitcoin Core builds";

    user = mkOption {
      type = types.str;
      default = "will";
      description = "User to run the bgt watcher service as";
    };

    autoAttest = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically attest using GPG and open PRs on GitHub";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra flags to pass to bgt watch start";
    };
  };

  config = mkIf cfg.enable {
    # Configure sops secret for GitHub token
    sops.secrets.github_bgt_token = {
      sopsFile = ../secrets/will.yaml;
      owner = cfg.user;
      mode = "0400";
    };

    systemd.user.services.bgt = {
      description = "BGT watcher daemon for automated Bitcoin Core builds";
      after = ["network-online.target" "gpg-agent.service"];
      wants = ["network-online.target"];
      wantedBy = ["default.target"];

      environment = {
        HOME = "/home/${cfg.user}";
        GNUPGHOME = "/home/${cfg.user}/.gnupg";
      };

      path = with pkgs; [
        gnupg
        git
        openssh
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = let
          flags = [] ++ optional cfg.autoAttest "--auto" ++ cfg.extraFlags;
        in "${pkgs.bash}/bin/bash -c 'export GITHUB_BGT_TOKEN=$(cat ${config.sops.secrets.github_bgt_token.path}) && /home/${cfg.user}/.cargo/bin/bgt watch start ${concatStringsSep " " flags}'";
        ExecStop = "${pkgs.bash}/bin/bash -c '/home/${cfg.user}/.cargo/bin/bgt watch stop'";
        Restart = "on-failure";
        RestartSec = "30s";
        StandardOutput = "file:/home/${cfg.user}/.config/bgt/watch.log";
        StandardError = "file:/home/${cfg.user}/.config/bgt/watch.log";

        # Ensure access to required directories
        ReadWritePaths = [
          "/home/${cfg.user}/.local/state/guix-builds"
          "/home/${cfg.user}/.config/bgt"
          "/home/${cfg.user}/.gnupg"
          "/run/secrets"
        ];

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        NoNewPrivileges = true;
      };
    };
  };
}
