{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      security.sudo = {
        enable = true;
        wheelNeedsPassword = true;
      };

      services.pcscd.enable = true;

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
