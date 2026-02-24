{ inputs, config, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      users.users.${username}.shell = pkgs.fish;
      programs.bash.interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        package = pkgs.fish;
        generateCompletions = true;
        preferAbbrs = true;

        shellInit = ''
          fish_add_path $HOME/.local/bin
          fish_add_path $HOME/go/bin
          fish_add_path /usr/local/go/bin
          fish_add_path $HOME/.cargo/bin
        '';

        loginShellInit = ''
          set -gx GPG_TTY (tty)
        '';

        interactiveShellInit = ''
          set -g fish_greeting

          fish_vi_key_bindings

          starship init fish | source
          zoxide init --cmd cd fish | source
          direnv hook fish | source

          set -g fzf_fd_opts --hidden --max-depth 5

          if functions -q fzf_configure_bindings
            fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
          end

          set fish_cursor_unknown block
          set fish_vi_force_cursor 1
        '';

        shellAbbrs = {
          bcli = "bitcoin-cli";
          cc = "claude";
          electrumtunnel = "ssh nucremote -L 50001:localhost:50001 -N";
          "fetch-master" =
            "git checkout master; and git fetch --all --tags --prune; and git merge upstream/master";
          "guix-hashes" =
            "uname -m; find guix-build-$(git rev-parse --short=12 HEAD)/output/ -type f -print0 | env LC_ALL=C sort -z | xargs -r0 sha256sum";
          "genesis-block" =
            "bitcoin-cli getblockhash 0 | xargs -I {} bitcoin-cli getblock {} 0 | xxd -r -p | hexdump -v -C";
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

          ll = "eza -al";
          lld = "eza -s modified -rl";
          llo = "eza -al -s newest";
          ls = "eza --icons --no-quotes";
          lslm = "ls -aFlhpt";
          lss = "ls -aFlhS";
          rm = "rm -i";

          htop = "TERM=xterm-256color htop";
          weechat = "TERM=xterm-256color weechat";
          which = "command -v";
          myip = "curl ifconfig.me";
          "speedtest-curl" = "curl -o /dev/null http://ipv4.download.thinkbroadband.com/1GB.zip";
          termbin = "nc termbin.com 9999";

          mvc = "sudo tailscale set --exit-node=de-dus-wg-001.mullvad.ts.net";
          mvd = "sudo tailscale set --exit-node=";

          mutt = "pushd $HOME/Downloads/; TERM=xterm-direct neomutt; popd";
          todo = "nvim ~/todo.txt";
          vim = "nvim";
          pip = "uv pip";
          notify = "say finished";

          "youtube-dl-best" = "youtube-dl -f bestvideo+bestaudio --merge-output-format mkv";
          "ytdl-audio" = "youtube-dl -x --audio-format best";
          "ytdl-list" = "youtube-dl -F";
          weather = "curl wttr.in/Frome\\\\\\?format=v2 \\&\\& curl wttr.in/Frome";
        };

        plugins = [
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      home.sessionVariables = {
        BASH = "${pkgs.bash}/bin/bash";
        CCACHE_DIR = "$HOME/.ccache";
        CCACHE_MAXSIZE = "25G";
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
        DETACHED_SIGS_REPO = "$HOME/src/bitcoin-detached-sigs";
        GUIX_SIGS_REPO = "$HOME/src/guix.sigs";
        SIGNER = "0xCE6EC49945C17EA6=willcl-ark";
        FZF_DEFAULT_COMMAND = "fd --type file --color=always";
        FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        DELTA_PAGER = "less -R";
        HOMEBREW_NO_AUTO_UPDATE = "1";
        PIP_REQUIRE_VIRTUALENV = "0";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
      };

      home.file = {
        ".config/fish/functions".source = "${inputs.self}/home/fish/functions";
        ".config/fish/completions".source = "${inputs.self}/home/fish/completions";
        ".config/fish/conf.d/kubecolor.fish".source = "${inputs.self}/home/fish/conf.d/kubecolor.fish";
        ".config/fish/conf.d/nix-env.fish".source = "${inputs.self}/home/fish/conf.d/nix-env.fish";
      };
    };
}
