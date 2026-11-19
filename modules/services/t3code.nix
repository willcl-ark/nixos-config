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
      services.tailscale.extraSetFlags = [ "--operator=${username}" ];

      systemd.services.t3code = {
        description = "T3 Code server";
        after = [
          "network-online.target"
          "tailscaled.service"
        ];
        wants = [
          "network-online.target"
          "tailscaled.service"
        ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          HOME = "/home/${username}";
          PATH = lib.mkForce "/etc/profiles/per-user/${username}/bin:/home/${username}/.nix-profile/bin:/run/current-system/sw/bin:/run/wrappers/bin";
        };
        serviceConfig = {
          User = username;
          WorkingDirectory = "/home/${username}";
          ExecStart = "${t3code}/bin/t3 serve --host 127.0.0.1 --port 3773 --tailscale-serve";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
