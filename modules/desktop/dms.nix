{ ... }:
{
  flake.modules.homeManager.desktop =
    { ... }:
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
    };
}
