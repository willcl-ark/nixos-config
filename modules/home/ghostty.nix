{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = pkgs.ghostty;
        settings = {
          font-family = "Comic Code";
          font-size = 10;
          font-feature = [
            "-calt"
            "-liga"
            "-dlig"
          ];
          cursor-style = "block";
          mouse-hide-while-typing = true;
          window-padding-x = 4;
          window-padding-y = 4;
          shell-integration = "fish";
          shell-integration-features = "no-cursor,ssh-terminfo,ssh-env";
          macos-titlebar-style = "hidden";
          scrollback-limit = 1000000000;
          window-inherit-working-directory = true;
          clipboard-paste-protection = false;

          quit-after-last-window-closed = true;
          quit-after-last-window-closed-delay = "5m";

        };
      };

      xdg.configFile."systemd/user/default.target.wants/app-com.mitchellh.ghostty.service".source =
        "${pkgs.ghostty}/share/systemd/user/app-com.mitchellh.ghostty.service";
    };
}
