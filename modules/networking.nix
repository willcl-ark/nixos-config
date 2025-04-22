{ config, lib, ... }:

with lib;

let
  cfg = config.networking.my;
in
{
  options.networking.my = {
    enableNetworkManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable NetworkManager";
    };

    enableFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the firewall";
    };

    openPorts = {
      tcp = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of TCP ports to open";
      };

      udp = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of UDP ports to open";
      };
    };

    enableTailscale = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Tailscale";
    };

    tailscaleAsRouter = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to configure Tailscale as a router";
    };
  };

  config = {
    networking = {
      networkmanager.enable = cfg.enableNetworkManager;

      firewall = mkIf cfg.enableFirewall {
        enable = true;
        allowedTCPPorts = cfg.openPorts.tcp;
        allowedUDPPorts = cfg.openPorts.udp;
        allowPing = true;
      };
    };

    services.tailscale = mkIf cfg.enableTailscale {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = if cfg.tailscaleAsRouter then "server" else "client";
    };

    # We always want this available
    services.openssh.enable = true;
  };
}
