{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # Migration draft; prerequisites and unported services are in docs/nuc-migration.md.
  configurations.nixos.nuc.module =
    { config, pkgs, ... }:
    {
      imports = [
        nixos.nuc-hardware
        nixos.nuc-media
        nixos.nuc-bitcoin
        nixos.nuc-utilities
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
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
      systemd.defaultUnit = "multi-user.target";

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "nuc-hm-backup";
        users.will = {
          imports = [ homeManager.nuc-terminal ];
          home.username = "will";
          home.homeDirectory = "/home/will";
        };
      };

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
          PermitRootLogin = "prohibit-password";
        };
      };
      services.tailscale = {
        enable = true;
        openFirewall = true;
        authKeyFile = config.sops.secrets.tailscale_auth_key.path;
        extraSetFlags = [ "--ssh" ];
      };
      sops.defaultSopsFile = ../../secrets/nuc.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.secrets.tailscale_auth_key = { };

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH988C5DbEPHfoCphoW23MWq9M6fmA4UTXREiZU0J7n0 will.hetzner@temp.com"
      ];

      programs.fish.enable = true;
      users.groups.will.gid = 1000;
      users.groups.bitcoin.gid = 1001;
      users.groups.media.gid = 1002;
      users.groups.dataaccess.gid = 1004;
      users.users.will = {
        isNormalUser = true;
        # Media services traverse this home to reach their existing state/downloads.
        homeMode = "755";
        uid = 1000;
        group = "will";
        extraGroups = [
          "wheel"
          "dataaccess"
        ];
        shell = pkgs.fish;
        # Administration uses root's SSH key; no password secret is required.
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
        autoconf
        automake
        binutils
        cmake
        gcc
        gdb
        git
        gnumake
        htop
        jq
        libtool
        lvm2
        ninja
        patch
        pkg-config
        python3
        ripgrep
        rsync
        smartmontools
      ];
      services.fstrim.enable = true;
      services.smartd.enable = true;
    };
}
