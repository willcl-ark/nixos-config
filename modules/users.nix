{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.users.my;
in {
  options.users.my = {
    defaultUser = mkOption {
      type = types.str;
      default = "will";
      description = "Default username";
    };

    createDefaultUser = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create the default user";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = ["wheel" "networkmanager" "audio" "docker"];
      description = "Extra groups for the default user";
    };

    hashedPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Hashed password for the default user";
      example = "$y$j9T$JV/cbQ/2QXvnouRK.3UPT0$9ZE12JKYtJPuQEfqHeEgl072NxE.VoTov2F/u7tyxD5";
    };

    defaultShell = mkOption {
      type = types.package;
      default = pkgs.fish;
      description = "Default shell for the default user";
    };

    enableFishShell = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the Fish shell";
    };
  };

  config = {
    users.users = mkIf cfg.createDefaultUser {
      ${cfg.defaultUser} = {
        isNormalUser = true;
        extraGroups = mkForce ["wheel" "networkmanager" "audio" "docker"];
        hashedPassword = cfg.hashedPassword;
        shell = cfg.defaultShell;
      };
    };

    programs.fish = mkIf cfg.enableFishShell {
      enable = true;
    };

    # Setup non-login bash shells to exec into fish shell
    # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    programs.bash = mkIf cfg.enableFishShell {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    # Disable very slow man-cache build due to fish's completions
    # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365
    documentation.man.generateCaches = false;
  };
}
