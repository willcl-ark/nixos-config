{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  # Common configuration shared between desktop and macbook

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.trusted-users = ["will"];
  };

  # Explicitly allow home-manager to use system packages
  home.enableNixpkgsReleaseCheck = false;

  # Common packages for all systems
  home.packages = with pkgs; [
    # Misc packages
    asciinema
    claude-code
    fastfetch
    tokei

    # Basic CLI tools
    curl
    git
    htop
    rsync
    tmux
    unzip
    wget

    # Development tools
    fd
    fzf
    jq
    ripgrep

    # Languages and runtimes
    go
    lua
    python312
    rustup
    zig

    # Development tools
    gh-dash
    qemu
    uv

    # Build tools
    bash
    clang_19
    cmake
    elfutils
    findutils
    gnugrep
    gnumake
    gnused
    gnutar
    mold
    ninja
    podman
    sqlite

    # Git-related
    delta
    difftastic
    lazygit

    # Email tools
    lynx
    notmuch-addrlookup
    ripmime
    urlscan

    # Linters
    actionlint
    gitlint
    lua54Packages.luacheck
    markdownlint-cli
    nodePackages.jsonlint
    ruff
    shellcheck
    yamllint
  ];

  # GPG configuration
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    homedir = "${config.home.homeDirectory}/.gnupg";
    settings = {
      use-agent = true;
    };
  };

  # Git configuration - force rebuild
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        conflict-style = "zdiff3";
      };
    };
    userName = "will";
    userEmail = "will@256k1.dev";
    signing = {
      key = "0xCE6EC49945C17EA6";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "master";
      diff.algorithm = "patience";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      gpg.program = "${pkgs.gnupg}/bin/gpg2";
    };
    aliases = {
      # Common commands
      a = "add .";
      b = "branch";
      cp = "cherry-pick";
      cpcont = "cherry-pick --continue";
      d = "difftool";
      ds = "diff --staged";
      f = "fetch --all --prune";
      lo = "log --oneline -n 40";
      m = "mergetool";
      po = "push origin";
      pu = "push upstream";
      pushf = "push --force-with-lease";
      r = "rebase";
      ra = "rebase --abort";
      rcont = "rebase --continue";
      rd = "range-diff";
      rem = "remote";
      rh = "reset --hard";
      s = "status";

      # File Management
      co = "checkout";
      cob = "checkout -b";
      un = "reset HEAD";

      # Commit Commands
      amend = "commit --amend";
      cm = "commit";
      com = "commit -m";
      fix = "commit --amend --no-edit";

      # Custom scripts (platform-agnostic)
      coauth = "!f() { git shortlog --summary --numbered --email --all | grep \"$1\" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*/Co-authored-by: /'; }; f";
      files = "!f() { git diff-tree --no-commit-id --name-only -r HEAD; }; f";
      fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
      last = "log -1 HEAD";
      pr = "!f() { git fetch $1 pull/$2/head:pr-$2 && git switch pr-$2; }; f";
      pru = "!f() { git fetch --update-head-ok -f $1 pull/$2/head:pr-$2; }; f";
      rb = "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch); }; f";
      rba = "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch) --autosquash; }; f";
      review = "!f() { git -c sequence.editor='sed -i s/pick/edit/' rebase -i $(git merge-base master HEAD); }; f";
      show-pr = "!f() { git log --merges --ancestry-path --oneline $1..HEAD | tail -n 1; }; f";
      tags = "!sh -c 'git for-each-ref --sort=-taggerdate --format=\"%(refname:lstrip=2)\" refs/tags | fzf | xargs git checkout'";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "-uu"
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
