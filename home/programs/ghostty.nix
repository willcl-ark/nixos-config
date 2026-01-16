{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "ComicCode Nerd Font";
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
    };
  };
}
