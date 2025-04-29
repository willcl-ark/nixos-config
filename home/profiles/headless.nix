{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.headless;
in {
  options.profiles.headless = {
    enable = mkEnableOption "Minimal profile (for servers/headless)";
  };

  config = mkIf cfg.enable {
    # Minimal CLI tools only
    home.packages = with pkgs; [
      tmux
      htop
      curl
      wget
      rsync
      git
    ];
  };
}
