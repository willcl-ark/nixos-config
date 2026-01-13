{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./gpg.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
  };

  home.enableNixpkgsReleaseCheck = false;

  home.packages = [
    # Misc
    pkgs.asciinema
    pkgs.claude-code
    pkgs.fastfetch
    pkgs.yt-dlp
    pkgs.tokei

    # CLI tools
    pkgs.curl
    pkgs.git
    pkgs.htop
    pkgs.rsync
    pkgs.tmux
    pkgs.unzip
    pkgs.wget

    # Dev tools
    pkgs.fd
    pkgs.fzf
    pkgs.gh-dash
    pkgs.jq
    pkgs.qemu
    pkgs.ripgrep
    pkgs.uv

    # Languages and runtimes
    pkgs.go
    pkgs.lua
    pkgs.python312
    pkgs.rustup
    pkgs.zig

    # Build tools
    pkgs.bash
    pkgs.clang_19
    pkgs.cmake
    pkgs.elfutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnumake
    pkgs.gnused
    pkgs.gnutar
    pkgs.mold
    pkgs.ninja
    pkgs.podman
    pkgs.sqlite

    # Git-related
    pkgs.delta
    pkgs.difftastic
    pkgs.lazygit

    # Email
    pkgs.lynx
    pkgs.notmuch-addrlookup
    pkgs.ripmime
    pkgs.urlscan

    # Linters
    pkgs.actionlint
    pkgs.gitlint
    pkgs.lua54Packages.luacheck
    pkgs.markdownlint-cli
    pkgs.ruff
    pkgs.shellcheck
    pkgs.yamllint
  ];

  programs.ripgrep = {
    enable = true;
    arguments = [
      "-u"
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      directory = {
        truncation_length = 3;
        truncate_to_repo = false;
      };
      gcloud.disabled = true;
      memory_usage.disabled = true;
      shlvl.disabled = true;
    };
  };

  programs.zoxide = {
    enable = true;
  };

  home.stateVersion = "25.05";
}
