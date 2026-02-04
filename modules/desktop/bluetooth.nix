{ ... }:
{
  flake.modules.nixos.desktop =
    { ... }:
    {
      hardware.bluetooth.enable = true;
      hardware.acpilight.enable = true;
      services.blueman.enable = true;
    };
}
