{ inputs, ... }:
{
  flake.modules.nixos.desktop-services =
    { config, ... }:
    {
      imports = [ inputs.mod-bot.nixosModules.default ];

      sops.secrets = {
        github_mod_bot_token.sopsFile = "${inputs.self}/secrets/will.yaml";
        telegram_mod_bot_token.sopsFile = "${inputs.self}/secrets/will.yaml";
      };

      sops.templates."mod-bot.env" = {
        mode = "0400";
        restartUnits = [ "mod-bot.service" ];
        content = ''
          GITHUB_TOKEN=${config.sops.placeholder.github_mod_bot_token}
          TELEGRAM_BOT_TOKEN=${config.sops.placeholder.telegram_mod_bot_token}
        '';
      };

      services.mod-bot = {
        enable = true;
        live = true;
        operatorId = 448332502;
        environmentFile = config.sops.templates."mod-bot.env".path;
      };
    };
}
