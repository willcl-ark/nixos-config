{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  # Migration draft; prerequisites and unported services are in docs/nuc-migration.md.
  configurations.nixos.nuc.module =
    { pkgs, ... }:
    {
      imports = [
        nixos.nuc-hardware
        nixos.nuc-media
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      time.timeZone = "Europe/London";
      i18n.defaultLocale = "en_GB.UTF-8";
      system.stateVersion = "26.05";

      networking.hostName = "will-nuc";
      networking.useDHCP = false;
      networking.interfaces.eno1.useDHCP = true;
      networking.firewall = {
        enable = true;
        interfaces.tailscale0.allowedTCPPorts = [
          22
          32400
          8989
          7878
        ];
        interfaces.eno1.allowedTCPPorts = [
          22
          32400
        ];
      };

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      programs.fish.enable = true;
      users.groups.will.gid = 1000;
      users.groups.bitcoin.gid = 1001;
      users.groups.media.gid = 1002;
      users.groups.dataaccess.gid = 1004;
      users.users.will = {
        isNormalUser = true;
        uid = 1000;
        group = "will";
        extraGroups = [
          "wheel"
          "dataaccess"
        ];
        shell = pkgs.fish;
        # Provision privately before activation; never put a password hash in Git.
        hashedPasswordFile = "/var/lib/nuc-secrets/will-password";
        # OpenSSH also reads the preserved /home/will/.ssh/authorized_keys.
      };
      users.users.bitcoin = {
        isSystemUser = true;
        uid = 1001;
        group = "bitcoin";
        extraGroups = [ "dataaccess" ];
        home = "/home/bitcoin";
      };
      security.sudo.wheelNeedsPassword = true;

      environment.systemPackages = with pkgs; [
        git
        htop
        jq
        lvm2
        ripgrep
        rsync
        smartmontools
      ];
      services.fstrim.enable = true;
      services.smartd.enable = true;
    };
}
