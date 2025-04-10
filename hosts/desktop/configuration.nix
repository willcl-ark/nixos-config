{ pkgs, ... }: {
  imports = [ ../../modules/common.nix ./nvidia.nix ];

  # Host-specific config
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    apcupsd
    pavucontrol
  ];

  hardware = {
    bluetooth.enable = true;
    acpilight.enable = true;
  };

  networking.hostName = "nix-desktop";

  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
  };
}
