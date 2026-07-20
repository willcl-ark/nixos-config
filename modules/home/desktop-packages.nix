{ inputs, ... }:
{
  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    let
      wf-recorder-gui = pkgs.callPackage ../../packages/wf-recorder-gui.nix { };
    in
    {
      home.username = "will";
      home.homeDirectory = "/home/will";

      home.packages = with pkgs; [
        bitwarden-desktop
        cider-2
        evince
        haruna
        keet
        kew
        mpv
        mullvad
        museeks
        networkmanagerapplet
        nix-output-monitor
        nzbget
        pwvucontrol
        grim
        rssguard
        satty
        slurp
        signal-desktop
        sparrow
        swayimg
        telegram-desktop
        tor-browser
        transmission_4-gtk
        vlc

        kubectl
        k9s
        helm
        k3d

        weechat
        nicotine-plus

        gnome-keyring
        fuzzel
        wl-clipboard

        wf-recorder
        wf-recorder-gui
      ];

      home.file.".local/bin/gh-issue-open.sh" = {
        text = ''
          #!/usr/bin/env bash
          issue=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Bitcoin Issue #: ")
          [ -n "$issue" ] && ${pkgs.firefox-devedition}/bin/firefox-devedition --new-tab "https://github.com/bitcoin/bitcoin/issues/$issue"
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

        gpg.scdaemonSettings = {
          reader-port = "Yubikey";
          disable-ccid = true;
        };

        git.settings.alias.ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | wl-copy; }; f";
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

      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
      };

      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        extraConfig = ''
          allow-loopback-pinentry
          pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
        '';
      };

      sops = {
        defaultSopsFile = "${inputs.self}/secrets/will.yaml";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
