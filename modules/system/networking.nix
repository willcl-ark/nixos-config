{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      networking.networkmanager.enable = true;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          8000
          2234
        ];
        allowPing = true;
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "client";
      };

      services.openssh.enable = true;
    };
}
