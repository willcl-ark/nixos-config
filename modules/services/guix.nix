{ ... }:
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.guix ];
      services.guix.enable = true;
    };
}
