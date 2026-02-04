{ ... }:
{
  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    {
      catppuccin = {
        enable = true;
        flavor = "macchiato";
      };

      programs.firefox = {
        enable = true;
        profiles.default = {
          isDefault = true;
          extensions.force = true;
          settings = {
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "media.ffmpeg.vaapi.enabled" = true;
            "gfx.webrender.all" = true;
            "layout.css.devPixelsPerPx" = "-1.0";
            "browser.display.use_system_colors" = true;
            "widget.disable-swipe-tracker" = false;
            "privacy.donottrackheader.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
          };
        };
      };

      xresources.properties = { };

      xdg.mimeApps = {
        enable = true;
        associations.added = {
          "application/pdf" = [ "org.gnome.Evince.desktop" ];
          "image/jpeg" = [ "swayimg.desktop" ];
          "image/png" = [ "swayimg.desktop" ];
          "image/gif" = [ "swayimg.desktop" ];
          "image/webp" = [ "swayimg.desktop" ];
        };
        defaultApplications = {
          "application/pdf" = [ "org.gnome.Evince.desktop" ];
          "image/jpeg" = [ "swayimg.desktop" ];
          "image/png" = [ "swayimg.desktop" ];
          "image/gif" = [ "swayimg.desktop" ];
          "image/webp" = [ "swayimg.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "text/html" = [ "firefox.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" ];
        };
      };

      xdg.configFile."mimeapps.list".force = true;
    };
}
