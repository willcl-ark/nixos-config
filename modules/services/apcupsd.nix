{ ... }:
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
    {
      services.apcupsd.enable = true;
      environment.systemPackages = [ pkgs.apcupsd ];
    };
}
