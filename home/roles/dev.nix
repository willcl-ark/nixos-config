{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.roles.dev;
in
{
  options.roles.dev = {
    enable = mkEnableOption "Dev role";

    enableGo = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Go development";
    };

    enablePython = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Python development";
    };

    enableRust = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Rust development";
    };

    enableK8s = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Kubernetes development tools";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Common development tools
      fzf
      ripgrep
      fd
      jq

      # Git tools
      git
      delta
      lazygit

      # Build tools
      cmake
      gnumake
      ninja

      # Docker containers
      docker
      podman

      # Language-specific packages
    ]
    ++ (if cfg.enableGo then [ pkgs.go ] else [ ])
    ++ (if cfg.enablePython then [ pkgs.python311 pkgs.uv ] else [ ])
    ++ (if cfg.enableRust then [ pkgs.rustup ] else [ ])
    ++ (if cfg.enableK8s then [ pkgs.kubectl pkgs.k9s pkgs.helm pkgs.k3d ] else [ ])
    ++ [
      # LSPs
      basedpyright
      clang-tools
      cmake-language-server
      fish-lsp
      gopls
      lua-language-server
      nil
      pyright
      typos-lsp
      zls

      # Linters
      actionlint
      gitlint
      lua54Packages.luacheck
      markdownlint-cli
      nodePackages.jsonlint
      ruff
      shellcheck
      yamllint

      # Formatters
      isort
      mdformat
      stylua
      typos
    ];

    programs.direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
      silent = true;
    };

    programs.fzf = {
      enable = true;
    };
  };
}
