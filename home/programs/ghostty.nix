{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "ComicCode Nerd Font";
      font-size = 9;
      font-feature = ["-calt" "-liga" "-dlig"];

      cursor-style = "block";

      mouse-hide-while-typing = true;

      window-padding-x = 4;
      window-padding-y = 4;

      shell-integration = "fish";
      shell-integration-features = "no-cursor";

      macos-titlebar-style = "hidden";

      scrollback-limit = 10000;
    };
  };
}
