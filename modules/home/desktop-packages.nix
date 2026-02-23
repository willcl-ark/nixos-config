{ inputs, ... }:
{
  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    let
      wf-recorder-gui-src = pkgs.fetchFromGitHub {
        owner = "ali205412";
        repo = "wf-recorder-gui";
        rev = "v0.4.0";
        hash = "sha256-/7ZtklccG6mnx0h73Zy9QkQzOyhSBRMvjExzxlzuppY=";
      };
      wf-recorder-gui = (pkgs.callPackage "${wf-recorder-gui-src}/package.nix" { }).overrideAttrs (old: {
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (old) src;
          hash = "sha256-rZOv00udcaNDmfv9ScYPf0nfFvBoi+gce2RAvCakx50=";
        };
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/wf-recorder-gui \
            --prefix LD_LIBRARY_PATH : ${
              pkgs.lib.makeLibraryPath (
                with pkgs;
                [
                  wayland
                  libxkbcommon
                  vulkan-loader
                ]
              )
            }
        '';
      });
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
        nzbget
        pwvucontrol
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

      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        extraConfig = ''
          allow-loopback-pinentry
          pinentry-program /run/current-system/sw/bin/pinentry-gnome3
        '';
      };

      sops = {
        defaultSopsFile = "${inputs.self}/secrets/will.yaml";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
