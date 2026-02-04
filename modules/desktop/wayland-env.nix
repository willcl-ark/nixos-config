{ ... }:
{
  flake.modules.nixos.desktop =
    { ... }:
    {
      environment.sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        NIXOS_OZONE_WL = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      services = {
        dbus.enable = true;
        udisks2 = {
          enable = true;
          mountOnMedia = true;
        };
        gnome.gnome-keyring.enable = true;
        libinput = {
          enable = true;
          mouse.naturalScrolling = true;
          touchpad.naturalScrolling = true;
        };
        xserver.enable = false;
      };

      security.polkit.enable = true;
      programs.dconf.enable = true;
    };
}
