{ config, pkgs, ... }: {
  home.username = "will";
  home.homeDirectory = "/home/will";

  imports = [
    ./programs/development.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/tmux.nix
    ./programs/sway.nix
  ];

  # Explicitly allow home-manager to use system packages
  home.enableNixpkgsReleaseCheck = false;

  # Make sure PATH includes system packages
  home.sessionPath = [ "/run/current-system/sw/bin" ];

  # Set Wayland environment variables
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    SDL_VIDEODRIVER = "wayland";
  };

  home.packages = with pkgs; [
    bitwarden
    borgbackup
    fastfetch
    firefox
    helm
    k3d
    k9s
    ksnip
    msmtp
    # mullvad
    # neomutt
    networkmanagerapplet
    nicotine-plus
    pavucontrol
    ruff
    signal-desktop
    tailscale
    tokei
    tor-browser
    urlscan
    uv
    vlc
    weechat
    wl-clipboard
  ];

  programs = {
    bash = {
      enable = true;
      bashrcExtra = "";
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    gpg = {
      enable = true;
      package = pkgs.gnupg;
      homedir = "${config.home.homeDirectory}/.gnupg";
      settings = {
        # Use a Yubikey reader
        reader-port = "Yubikey";
        # Always use the card
        use-agent = true;
        # Cache for 10 minutes
        default-cache-ttl = "600";
      };
    };

    git = {
      enable = true;
      delta.enable = true;
      userName = "will";
      userEmail = "will@256k1.dev";
      signing = {
        key = "0xCE6EC49945C17EA6";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "master";
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
        lo = "log --oneline -n 20";
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

        # Custom scripts
        show-pr =
          "!f() { git log --merges --ancestry-path --oneline $1..HEAD | tail -n 1; }; f";
        ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | xsel -b; }; f";
        files = "!f() { git diff-tree --no-commit-id --name-only -r HEAD; }; f";
        fixup =
          "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
        last = "log -1 HEAD";
        rb =
          "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch); }; f";
        rba =
          "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch) --autosquash; }; f";
        review =
          "!f() { git -c sequence.editor='sed -i s/pick/edit/' rebase -i $(git merge-base master HEAD); }; f";
        tags =
          "!sh -c 'git for-each-ref --sort=-taggerdate --format=\"%(refname:lstrip=2)\" refs/tags | fzf | xargs git checkout'";
      };
      delta.options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          commit-style = "raw";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "line-numbers decorations mellow-barbet";
        whitespace-error-style = "22 reverse";
      };
    };

    starship = {
      enable = true;
      settings = {
        directory.truncation_length = 3;
        gcloud.disabled = true;
        memory_usage.disabled = true;
        shlvl.disabled = false;
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      # enableSshSupport = true;
      enableExtraSocket = true;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };

  home.stateVersion = "24.11";
}
