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
        package = pkgs.firefox-devedition;
        configPath = ".mozilla/firefox";
        profiles.dev-edition-default = {
          isDefault = true;
          path = "ac0mwoe8.dev-edition-default";
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
            "xpinstall.signatures.required" = false;
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
          "x-scheme-handler/http" = [ "firefox-devedition.desktop" ];
          "x-scheme-handler/https" = [ "firefox-devedition.desktop" ];
          "text/html" = [ "firefox-devedition.desktop" ];
          "application/xhtml+xml" = [ "firefox-devedition.desktop" ];
        };
      };

      xdg.configFile."mimeapps.list".force = true;
    };
}
