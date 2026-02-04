{ ... }:
{
  flake.modules.nixos.desktop-services =
    { ... }:
    {
      services.tor = {
        enable = true;
        client.enable = true;
        settings.ControlPort = 9051;
      };
    };
}
