{ inputs, config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.desktop-services =
    { pkgs, lib, ... }:
    let
      t3code = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.t3code;
    in
    {
      systemd.services.t3code = {
        description = "T3 Code server";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          HOME = "/home/${username}";
          PATH = lib.mkForce "/etc/profiles/per-user/${username}/bin:/home/${username}/.nix-profile/bin:/run/current-system/sw/bin:/run/wrappers/bin";
        };
        serviceConfig = {
          User = username;
          WorkingDirectory = "/home/${username}";
          ExecStart = "${t3code}/bin/t3 serve --host 127.0.0.1 --port 3773";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      systemd.services.t3code-tailscale = {
        description = "T3 Code Tailscale HTTPS proxy";
        after = [ "tailscaled.service" ];
        requires = [ "tailscaled.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 --yes http://127.0.0.1:3773";
          ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
