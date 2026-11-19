{ ... }:
{
  flake.modules.homeManager.nuc-terminal = {
    home.stateVersion = "26.05";
    xdg.mime.enable = false;
    fonts.fontconfig.enable = false;
    manual.manpages.enable = false;

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
        fish_vi_key_bindings
      '';
      shellAbbrs = {
        bcli = "bitcoin-cli";
        ll = "ls -alh";
        vim = "nvim";
        grc = "git rebase --continue";
      };
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        username.show_always = true;
        hostname.ssh_only = false;
        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
        };
        aws.disabled = true;
        gcloud.disabled = true;
      };
    };

    programs.git = {
      enable = true;
      ignores = [ ".worktrees" ];
      settings = {
        user = {
          name = "will";
          email = "will@256k1.dev";
        };
        init.defaultBranch = "master";
        diff.algorithm = "patience";
        merge.conflictStyle = "diff3";
        rerere.enabled = true;
        rerere.autoUpdate = true;
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        alias = {
          a = "add .";
          b = "branch";
          co = "checkout";
          cob = "checkout -b";
          ds = "diff --staged";
          f = "fetch --all --prune";
          lo = "log --oneline -n 40";
          pushf = "push --force-with-lease";
          ra = "rebase --abort";
          rcont = "rebase --continue";
          rd = "range-diff";
          s = "status";
        };
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    programs.htop = {
      enable = true;
      settings = {
        hide_kernel_threads = false;
        hide_userland_threads = false;
        show_program_path = true;
        highlight_base_name = true;
        highlight_megabytes = true;
        highlight_threads = true;
        enable_mouse = true;
        delay = 15;
      };
    };

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--max-columns=300"
        "--max-columns-preview"
        "--type-add=adoc:*.{adoc,asciidoc,asc}*"
      ];
    };

    programs.tmux = {
      enable = true;
      shortcut = "a";
      baseIndex = 1;
      mouse = true;
      historyLimit = 100000;
      terminal = "tmux-256color";
      keyMode = "vi";
      escapeTime = 0;
      extraConfig = ''
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-selection-and-cancel
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind L last-window
        set -g set-titles on
        set -g set-titles-string "#T"
        set -g status-right ""
        set -g focus-events on
      '';
    };

    # Keep an editor available; the old plugin trees need a separate review.
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
    };
  };
}
