{ config, pkgs, ... }: {
  home.username = "will";
  home.homeDirectory = "/home/will";

  imports = [
    ./programs/development.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
  ];

  home.packages = with pkgs; [
    # General dev tools
    bat
    curl
    eza
    fd
    fzf
    htop
    jq
    just
    magic-wormhole
    mosh
    ripgrep
    ruff
    time
    uv

    # GUI
    firefox

    # Audio
    imv # Image viewer
    networkmanagerapplet # Network management GUI
    pavucontrol

    # Other
    bitwarden
    signal-desktop
    tailscale
    vlc
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
      userName = "will";
      userEmail = "will@256k1.dev";
      signing = {
        key = null; # Let GPG decide which key to use
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
        st = "status";
        co = "checkout";
        c = "commit";
        b = "branch";
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
