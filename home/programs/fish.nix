{pkgs, ...}: {
  programs.fish = {
    enable = true;
    package = pkgs.fish;
    generateCompletions = true;
    preferAbbrs = true; # more fish-like

    # non-interactive
    shellInit = ''
      # Path management (from paths.fish)
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/go/bin
      fish_add_path /usr/local/go/bin
      fish_add_path $HOME/.cargo/bin
    '';

    loginShellInit = ''
      # Set GPG_TTY for gpg operations
      set -gx GPG_TTY (tty)
    '';

    # Interactive shell initialization
    interactiveShellInit = ''
      # Disable fish greeting
      set -g fish_greeting

      # Use vim keybindings
      fish_vi_key_bindings

      # Tool integrations
      starship init fish | source
      zoxide init --cmd cd fish | source
      direnv hook fish | source

      # FZF configuration
      set -g fzf_fd_opts --hidden --max-depth 5

      # FZF bindings (if fzf-fish plugin is available)
      if functions -q fzf_configure_bindings
        fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
      end

      set fish_cursor_unknown block
      set fish_vi_force_cursor 1

    '';

    shellAbbrs = {
      # Bitcoin Core development
      bcli = "bitcoin-cli";
      electrumtunnel = "ssh nucremote -L 50001:localhost:50001 -N";
      "fetch-master" = "git checkout master; and git fetch --all --tags --prune; and git merge upstream/master";
      "guix-hashes" = "find guix-build-$(git rev-parse --short=12 HEAD)/output/ -type f -print0 | env LC_ALL=C sort -z | xargs -r0 sha256sum";
      "genesis-block" = "bitcoin-cli getblockhash 0 | xargs -I {} bitcoin-cli getblock {} 0 | xxd -r -p | hexdump -v -C";
      grc = "git rebase --continue";
      lcli = "lightning-cli";
      rba = "git rebase -i (git merge-base HEAD upstream/master)";
      rcli = "bitcoin-cli -regtest";
      tb = "./build/bin/bitcoin";
      tbcli = "./build/bin/bitcoin-cli";
      "tbitcoin-qt" = "./build/bin/bitcoin-qt";
      tbitcoind = "./build/bin/bitcoind";
      tbwallet = "./build/bin/bitcoin-wallet";
      wasabitunnel = "ssh nucremote -L 8333:localhost:8333 -N";

      # File operations
      ll = "eza -al";
      lld = "eza -s modified -rl";
      llo = "eza -al -s newest";
      ls = "eza --icons --no-quotes";
      lslm = "ls -aFlhpt";
      lss = "ls -aFlhS";
      rm = "rm -i";

      # System utilities
      htop = "TERM=xterm-256color htop";
      weechat = "TERM=xterm-256color weechat";
      which = "command -v";
      myip = "curl ifconfig.me";
      "speedtest-curl" = "curl -o /dev/null http://ipv4.download.thinkbroadband.com/1GB.zip";
      termbin = "nc termbin.com 9999";

      # VPN
      mvc = "sudo tailscale set --exit-node=se-sto-wg-201.mullvad.ts.net";
      mvd = "sudo tailscale set --exit-node=";

      # Applications
      mutt = "pushd $HOME/Downloads/; neomutt; popd";
      todo = "nvim ~/todo.txt";
      vim = "nvim";
      pip = "uv pip";
      notify = "say finished";

      # misc
      "youtube-dl-best" = "youtube-dl -f bestvideo+bestaudio --merge-output-format mkv";
      "ytdl-audio" = "youtube-dl -x --audio-format best";
      "ytdl-list" = "youtube-dl -F";
      weather = "curl wttr.in/Frome\\\?format=v2 \&\& curl wttr.in/Frome";
    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
  };

  # FZF configuration for fish integration
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  home.sessionVariables = {
    # Dev tools
    BASH = "${pkgs.bash}/bin/bash";
    CCACHE_DIR = "$HOME/.ccache";
    CCACHE_MAXSIZE = "25G";
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";

    # Git and development
    DETACHED_SIGS_REPO = "$HOME/src/bitcoin-detached-sigs";
    GUIX_SIGS_REPO = "$HOME/src/guix.sigs";
    SIGNER = "0xCE6EC49945C17EA6=willcl-ark";

    # FZF
    FZF_DEFAULT_COMMAND = "fd --type file --color=always";
    FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";

    # Other tools
    DELTA_PAGER = "less -R";
    HOMEBREW_NO_AUTO_UPDATE = "1";
    PIP_REQUIRE_VIRTUALENV = "0";

    # XDG directories
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Custom functions and completions from dotfiles
  home.file = {
    ".config/fish/functions" = {
      source = ../fish/functions;
    };
    ".config/fish/completions" = {
      source = ../fish/completions;
    };
    # Note: conf.d files are handled by programs.fish.plugins above
    # Individual conf.d files that don't conflict with plugins:
    ".config/fish/conf.d/kubecolor.fish" = {
      source = ../fish/conf.d/kubecolor.fish;
    };
    ".config/fish/conf.d/nix-env.fish" = {
      source = ../fish/conf.d/nix-env.fish;
    };
  };
}
