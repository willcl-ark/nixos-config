{ config, lib, pkgs, ... }:

with lib;

{
  home.username = "will";
  home.homeDirectory = "/home/will";

  # Import profiles and roles
  imports = [
    ../profiles
    ../roles
    ./programs/tmux.nix
    # Temporarily disable home-manager fish config to use system fish with existing dotfiles
    # ./programs/fish.nix
    ./programs/ghostty.nix
  ];

  # Enable specific profiles and roles
  profiles.desktop.enable = true; # Enable desktop profile

  roles = {
    dev = {
      enable = true;
      enableGo = true;
      enablePython = true;
      enableRust = true;
      enableK8s = true; # Kubernetes tools
    };

    email.enable = true; # Email client
    messaging.enable = true; # Messaging applications
  };

  # Explicitly allow home-manager to use system packages
  home.enableNixpkgsReleaseCheck = false;

  # Additional packages not covered by roles or profiles
  home.packages = with pkgs; [
    asciinema
    claude-code
    fastfetch
    nzbget
    tokei
  ];

  # GPG configuration
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    homedir = "${config.home.homeDirectory}/.gnupg";
    settings = {
      # Always use the card
      use-agent = true;
    };
    scdaemonSettings = {
      # Use a Yubikey reader
      reader-port = "Yubikey";
      disable-ccid = true;
    };
  };

  # Git configuration
  programs.git = {
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
      core.editor = "${pkgs.neovim}/bin/nvim";
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
      ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | wl-copy; }; f";
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
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      directory.truncation_length = 3;
      gcloud.disabled = true;
      memory_usage.disabled = true;
      shlvl.disabled = true;
    };
  };

  programs.zoxide = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program /run/current-system/sw/bin/pinentry-gnome3
    '';
  };

  home.stateVersion = "25.05";
}
