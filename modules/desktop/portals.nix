{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
        configPackages = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
      };

      environment.etc."niri/niri-portals.conf".text = ''
        [preferred]
        default=gtk
        org.freedesktop.impl.portal.Screencast=gnome
        org.freedesktop.impl.portal.Screenshot=gnome
      '';
    };
}
