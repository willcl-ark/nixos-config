{
  config,
  pkgs,
  ...
}:
{
  home.file.".config/DankMaterialShell/catppuccin-macchiato.json" = {
    text = builtins.toJSON {
      dark = {
        name = "Catppuccin Macchiato Dark";
        primary = "#8aadf4";
        primaryText = "#181926";
        primaryContainer = "#7dc4e4";
        secondary = "#c6a0f6";
        surface = "#363a4f";
        surfaceText = "#cad3f5";
        surfaceVariant = "#494d64";
        surfaceVariantText = "#b8c0e0";
        surfaceTint = "#8aadf4";
        background = "#24273a";
        backgroundText = "#cad3f5";
        outline = "#6e738d";
        surfaceContainer = "#1e2030";
        surfaceContainerHigh = "#363a4f";
        error = "#ed8796";
        warning = "#eed49f";
        info = "#8bd5ca";
        matugen_type = "scheme-tonal-spot";
      };
    };
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
  };

  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = false;
      enableSpawn = false;
      includes.filesToInclude = [
        "alttab"
        "binds"
        "colors"
        "layout"
        "wpblur"
      ];
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = false;
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      extensions.force = true;
      settings = {
        # Wayland support
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
        "layout.css.devPixelsPerPx" = "-1.0";

        # Better integration
        "browser.display.use_system_colors" = true;
        "widget.disable-swipe-tracker" = false;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };

  xresources.properties = {
  };

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
}
