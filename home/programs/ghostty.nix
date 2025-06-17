{pkgs, ...}: {
  home.packages = with pkgs; [ghostty];

  home.file.".config/ghostty/config".text = ''
    font-family = ComicCode Nerd Font
    font-size = 9
    font-feature = -calt
    font-feature = -liga
    font-feature = -dlig

    cursor-style = block

    mouse-hide-while-typing = true

    theme = catppuccin-macchiato

    window-padding-x = 4
    window-padding-y = 4

    shell-integration = fish
    shell-integration-features = no-cursor

    macos-titlebar-style = hidden
    # window-decoration = false

    # 10 MB
    scrollback-limit = 10000
  '';
}
