{ inputs, ... }:
{
  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.radicle-node ];

      sops.secrets.radicle_node_private_key = {
        sopsFile = "${inputs.self}/secrets/will.yaml";
        path = "${config.home.homeDirectory}/.radicle/keys/radicle";
        mode = "0400";
      };

      home.file.".radicle/keys/radicle.pub".text =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGv7luDpz/a7xaLkPVszldgkSygBwHXoqiQYaqmPv2Ln radicle";
    };
}
