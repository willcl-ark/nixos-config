{
  config,
  pkgs,
  ...
}:
{
  home.username = "will";
  home.homeDirectory = "/home/will";

  imports = [
    ./common.nix
    ./email.nix
    ./theming.nix
    ./programs/tmux.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
  ];

  home.packages = [
    # GUI
    pkgs.bitwarden-desktop
    pkgs.cider-2
    pkgs.evince
    pkgs.haruna
    pkgs.keet
    pkgs.kew
    pkgs.mpv
    pkgs.mullvad
    pkgs.museeks
    pkgs.networkmanagerapplet
    pkgs.nzbget
    pkgs.pwvucontrol
    pkgs.signal-desktop
    pkgs.sparrow
    pkgs.swayimg
    pkgs.telegram-desktop
    pkgs.tor-browser
    pkgs.transmission_4-gtk
    pkgs.vlc

    # Kubernetes tools (desktop-specific)
    pkgs.kubectl
    pkgs.k9s
    pkgs.helm
    pkgs.k3d

    # Messaging
    pkgs.weechat
    pkgs.nicotine-plus

    # Wayland/niri
    pkgs.gnome-keyring
    pkgs.fuzzel
  ];

  home.file.".local/bin/gh-issue-open.sh" = {
    text = ''
      #!/usr/bin/env bash
      issue=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Bitcoin Issue #: ")
      [ -n "$issue" ] && ${pkgs.firefox}/bin/firefox --new-tab "https://github.com/bitcoin/bitcoin/issues/$issue"
    '';
    executable = true;
  };

  programs = {
    direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
      silent = true;
    };
    fzf.enable = true;
    bat.enable = true;

    # Desktop-specific GPG config (Yubikey)
    gpg.scdaemonSettings = {
      reader-port = "Yubikey";
      disable-ccid = true;
    };

    # Desktop-specific git alias (wl-copy)
    git.settings.alias = {
      ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | wl-copy; }; f";
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program /run/current-system/sw/bin/pinentry-gnome3
    '';
  };

  sops = {
    defaultSopsFile = ../secrets/will.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
