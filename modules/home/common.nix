{ inputs, ... }:
{
  flake.modules.homeManager.base =
    { lib, pkgs, ... }:
    {
      nix.package = lib.mkDefault pkgs.nix;

      home.enableNixpkgsReleaseCheck = false;

      home.packages =
        with pkgs;
        lib.optionals stdenv.hostPlatform.isLinux [ elfutils ]
        ++ [
          asciinema
          claude-code
          opencode
          fastfetch
          yt-dlp
          tokei

          curl
          git
          htop
          rsync
          tmux
          unzip
          wget

          fd
          fzf
          gh-dash
          jq
          qemu
          ripgrep
          uv

          go
          lua
          python312
          rustup
          zig

          bash
          clang_19
          cmake
          findutils
          gnugrep
          gnumake
          gnused
          gnutar
          mold
          ninja
          podman
          sqlite

          delta
          difftastic
          lazygit

          lynx
          notmuch-addrlookup
          ripmime
          urlscan

          actionlint
          gitlint
          lua54Packages.luacheck
          markdownlint-cli
          ruff
          shellcheck
          yamllint
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
