{ ... }:
{
  flake.modules.homeManager.base =
    { lib, pkgs, ... }:
    {
      nix.package = lib.mkDefault pkgs.nix;

      home.enableNixpkgsReleaseCheck = false;

      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.elfutils ] ++ [
        pkgs.actionlint
        pkgs.asciinema
        pkgs.bash
        pkgs.clang_19
        pkgs.claude-code
        pkgs.cmake
        pkgs.codex
        pkgs.curl
        pkgs.delta
        pkgs.difftastic
        pkgs.fastfetch
        pkgs.fd
        pkgs.findutils
        pkgs.fzf
        pkgs.gh-dash
        pkgs.git
        pkgs.gitlint
        pkgs.gnugrep
        pkgs.gnumake
        pkgs.gnused
        pkgs.gnutar
        pkgs.go
        pkgs.htop
        pkgs.jq
        pkgs.lazygit
        pkgs.lua
        pkgs.lua54Packages.luacheck
        pkgs.lynx
        pkgs.markdownlint-cli
        pkgs.mergiraf
        pkgs.mold
        pkgs.ninja
        pkgs.notmuch-addrlookup
        pkgs.opencode
        pkgs.podman
        pkgs.python312
        pkgs.qemu
        pkgs.ripgrep
        pkgs.ripmime
        pkgs.rsync
        pkgs.ruff
        pkgs.rustup
        pkgs.shellcheck
        pkgs.sqlite
        pkgs.tmux
        pkgs.tokei
        pkgs.unzip
        pkgs.urlscan
        pkgs.uv
        pkgs.wget
        pkgs.yamllint
        pkgs.yt-dlp
        pkgs.zig
      ];

      programs.ripgrep = {
        enable = true;
        arguments = [ "-u" ];
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

      programs.zoxide.enable = true;

      home.stateVersion = "25.05";
    };
}
