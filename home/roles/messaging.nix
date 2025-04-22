{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.roles.messaging;
in
{
  options.roles.messaging = {
    enable = mkEnableOption "Messaging client role";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
      telegram-desktop
      weechat
      nicotine-plus
    ];
  };
}
