{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
}
