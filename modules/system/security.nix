{ config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      security.sudo = {
        enable = true;
        wheelNeedsPassword = true;
      };

      services.pcscd.enable = true;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (subject.user === "${username}" &&
              (action.id === "org.debian.pcsc-lite.access_pcsc" ||
               action.id === "org.debian.pcsc-lite.access_card")) {
            return polkit.Result.YES;
          }
        });
      '';

      environment.systemPackages = [
        pkgs.gnupg
        pkgs.yubikey-personalization
        pkgs.yubikey-manager
        pkgs.pcsclite
      ];

      services.udev.packages = [
        pkgs.yubikey-personalization
        pkgs.libu2f-host
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
}
