{ inputs, ... }:
{
  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.halloy ];

      sops.secrets.irc_password = {
        sopsFile = "${inputs.self}/secrets/will.yaml";
      };

      home.file."${config.xdg.configHome}/halloy/themes/catppuccin-macchiato.toml".source =
        "${inputs.self}/home/halloy/catppuccin-macchiato.toml";

      sops.templates."halloy/config.toml" = {
        path = "${config.xdg.configHome}/halloy/config.toml";
        content = ''
          theme = "catppuccin-macchiato"
          check_for_update_on_launch = false

          [servers.soju]
          nickname = "willcl-ark"
          server = "100.104.49.27"
          port = 6667
          use_tls = false

          [servers.soju.sasl.plain]
          username = "willcl-ark@nixos"
          password = "${config.sops.placeholder.irc_password}"

          [font]
          family = "Comic Code"

          [buffer.chathistory]
          infinite_scroll = true

          [buffer.server_messages]
          join.smart = 900
          part.smart = 900
          quit.smart = 900
          change_nick.smart = 900

          [buffer.internal_messages]
          success.smart = 300
          error.smart = 300

          [highlights.nickname]
          case_insensitive = true

          [[highlights.match]]
          regex = 'pushed tag v[\d.]+'
          sound = "dong"

          [notifications]
          direct_message = { show_toast = true, show_content = true, sound = "peck" }
          highlight = { show_toast = true, show_content = true, sound = "ring" }

          [preview]
          enabled = false
        '';
      };
    };
}
