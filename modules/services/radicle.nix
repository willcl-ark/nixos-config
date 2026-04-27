{ config, inputs, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.desktop-services =
    { config, ... }:
    {
      sops.secrets.radicle_node_private_key = {
        sopsFile = "${inputs.self}/secrets/will.yaml";
        owner = "radicle";
        group = "radicle";
        mode = "0400";
      };

      services.radicle = {
        enable = true;
        privateKey = config.sops.secrets.radicle_node_private_key.path;
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGv7luDpz/a7xaLkPVszldgkSygBwHXoqiQYaqmPv2Ln radicle";
        node.openFirewall = true;
        settings = {
          preferredSeeds = [ ];
          node = {
            alias = username;
            relay = "always";
            seedingPolicy = {
              default = "allow";
              scope = "all";
            };
          };
        };
      };
    };
}
