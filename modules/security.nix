{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.security.my;
in {
  options.security.my = {
    enableYubikey = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable YubiKey support";
    };

    enableKeyd = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable keyd for keyboard remapping";
    };

    remapCapsToEsc = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to remap Caps Lock to Escape";
    };

    gpg = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable GPG";
      };

      enableSSHSupport = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable SSH support for GPG";
      };
    };
  };

  config = {
    # YubiKey support
    services.pcscd.enable = cfg.enableYubikey;
    environment.systemPackages = with pkgs;
      (
        if cfg.enableYubikey
        then [
          gnupg
          yubikey-personalization
          yubikey-manager
          pcsclite
        ]
        else []
      )
      ++ (
        if cfg.enableKeyd
        then [
          keyd
        ]
        else []
      );

    services.udev.packages = mkIf cfg.enableYubikey [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];

    # Keyboard remapping
    services.keyd = mkIf cfg.enableKeyd {
      enable = true;
      keyboards = {
        default = {
          ids = ["*"]; # Apply to all keyboards
          settings = {
            main = mkIf cfg.remapCapsToEsc {
              "capslock" = "esc";
            };
          };
        };
      };
    };

    programs.gnupg.agent = mkIf cfg.gpg.enable {
      enable = true;
      enableSSHSupport = cfg.gpg.enableSSHSupport;
    };
  };
}
