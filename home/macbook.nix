{
  config,
  lib,
  pkgs,
  ...
}: {
  # Macbook configuration

  home.username = "will";
  home.homeDirectory = "/Users/will";

  # Import common config
  imports = [
    ./common.nix
  ];

  # Macbook-specific packages
  home.packages = with pkgs; [
    # macOS-only pkgs
  ];

  # Development tools configuration
  programs = {
    direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
      silent = true;
    };

    fzf.enable = true;

    # Macbook-specific git aliases
    git.aliases = {
      # macOS-specific clipboard command pbcopy
      ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | pbcopy; }; f";
    };
  };

  # User configuration
  sops = {
    defaultSopsFile = ../secrets/will.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  # Note: GPG agent config will be different on macOS
  # services.gpg-agent not available on Darwin
}
