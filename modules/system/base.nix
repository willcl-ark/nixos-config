{ inputs, config, ... }:
let
  username = config.flake.meta.owner.username;
  ned = inputs.ned;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.trusted-users = [ username ];

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = [
        pkgs.bat
        pkgs.curl
        pkgs.dig
        pkgs.eza
        pkgs.fd
        pkgs.file
        pkgs.fzf
        pkgs.git
        pkgs.htop
        pkgs.imagemagick
        pkgs.jq
        pkgs.just
        pkgs.keyd
        pkgs.magic-wormhole
        pkgs.mosh
        pkgs.ncdu
        ned.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.nettools
        pkgs.nfs-utils
        pkgs.nh
        pkgs.pinentry-curses
        pkgs.pinentry-gnome3
        pkgs.pinentry-tty
        pkgs.ripgrep
        pkgs.rsync
        pkgs.sops
        pkgs.stow
        pkgs.time
        pkgs.tree
        pkgs.wget
        pkgs.bitcoind
        pkgs.borgbackup
        pkgs.btop
        pkgs.cachix
      ];

      hardware.enableAllFirmware = true;

      services.keyd = {
        enable = true;
        keyboards = {
          default = {
            ids = [ "*" ];
            settings = {
              main = {
                "capslock" = "esc";
                "f15" = "print";
              };
            };
          };
        };
      };

      time.timeZone = "Europe/London";
      i18n.defaultLocale = "en_GB.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_NUMERIC = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };

      system.stateVersion = "25.05";

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 10d --keep 10";
        flake = "/home/${username}/src/nixos-config";
      };
    };
}
