{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.roles.email;
in
{
  options.roles.email = {
    enable = mkEnableOption "Email client role";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neomutt
      msmtp
      notmuch
      notmuch-addrlookup
      offlineimap
      urlscan
      lynx # For viewing HTML emails in neomutt
    ];
  };
}
