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
    ./programs/tmux.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
  ];

  home.packages = with pkgs; [
    # GUI
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

    # Kubernetes tools (desktop-specific)
    kubectl
    k9s
    helm
    k3d

    # Messaging
    weechat
    nicotine-plus

    # Wayland/niri
    gnome-keyring
    fuzzel
  ];

  # Scripts for custom keybinds
  home.file.".local/bin/gh-issue-open.sh" = {
    text = ''
      #!/usr/bin/env bash
      issue=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Bitcoin Issue #: ")
      [ -n "$issue" ] && ${pkgs.firefox}/bin/firefox --new-tab "https://github.com/bitcoin/bitcoin/issues/$issue"
    '';
    executable = true;
  };

  home.file.".config/DankMaterialShell/catppuccin-macchiato.json" = {
    text = builtins.toJSON {
      dark = {
        name = "Catppuccin Macchiato Dark";
        primary = "#8aadf4";
        primaryText = "#181926";
        primaryContainer = "#7dc4e4";
        secondary = "#c6a0f6";
        surface = "#363a4f";
        surfaceText = "#cad3f5";
        surfaceVariant = "#494d64";
        surfaceVariantText = "#b8c0e0";
        surfaceTint = "#8aadf4";
        background = "#24273a";
        backgroundText = "#cad3f5";
        outline = "#6e738d";
        surfaceContainer = "#1e2030";
        surfaceContainerHigh = "#363a4f";
        error = "#ed8796";
        warning = "#eed49f";
        info = "#8bd5ca";
        matugen_type = "scheme-tonal-spot";
      };
    };
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

    # email
    mbsync.enable = true;
    msmtp.enable = true;
    notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync --all";
      };
      new = {
        tags = [
          "unread"
          "inbox"
        ];
        ignore = [
          ".mbsyncstate"
          ".uidvalidity"
        ];
      };
      search.excludeTags = [
        "deleted"
        "spam"
      ];
      maildir.synchronizeFlags = true;
    };
    neomutt = {
      enable = true;
      binds = [
        # navigation
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\Cd";
          action = "half-down";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\Cu";
          action = "half-up";
        }
        {
          map = [ "index" ];
          key = "g";
          action = "noop";
        }
        {
          map = [ "index" ];
          key = "gg";
          action = "first-entry";
        }
        {
          map = [ "index" ];
          key = "G";
          action = "last-entry";
        }
        {
          map = [ "pager" ];
          key = "g";
          action = "noop";
        }
        {
          map = [ "pager" ];
          key = "gg";
          action = "top";
        }
        {
          map = [ "pager" ];
          key = "G";
          action = "bottom";
        }

        # Additional vim-like bindings
        {
          map = [ "index" ];
          key = "j";
          action = "next-entry";
        }
        {
          map = [ "index" ];
          key = "k";
          action = "previous-entry";
        }
        {
          map = [ "pager" ];
          key = "j";
          action = "next-line";
        }
        {
          map = [ "pager" ];
          key = "k";
          action = "previous-line";
        }

        # Sidebar nav
        {
          map = [
            "index"
            "pager"
          ];
          key = "<down>";
          action = "sidebar-next";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "<up>";
          action = "sidebar-prev";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "<right>";
          action = "sidebar-open";
        }

        # Other
        {
          map = [
            "index"
            "pager"
          ];
          key = "@";
          action = "compose-to-sender";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "R";
          action = "group-reply";
        }
        {
          map = [ "index" ];
          key = "D";
          action = "purge-message";
        }
        {
          map = [ "index" ];
          key = "<tab>";
          action = "sync-mailbox";
        }
        {
          map = [ "index" ];
          key = "<space>";
          action = "collapse-thread";
        }
        {
          map = [ "attach" ];
          key = "<return>";
          action = "view-mailcap";
        }
        {
          map = [ "editor" ];
          key = "<tab>";
          action = "complete-query";
        }

        # Drafts
        {
          map = [ "compose" ];
          key = "P";
          action = "postpone-message";
        }
        {
          map = [ "index" ];
          key = "p";
          action = "recall-message";
        }

        # Notmuch search
        {
          map = [ "index" ];
          key = "X";
          action = "vfolder-from-query";
        }
      ];

      macros = [
        # Archive message
        {
          map = [
            "index"
            "pager"
          ];
          key = "A";
          action = "<save-message>=Archive<enter>";
        }

        # Sync email
        {
          map = [ "index" ];
          key = "O";
          action = "<shell-escape>mbsync -a<enter>";
        }

        # Mark as read
        {
          map = [ "index" ];
          key = "\\Cr";
          action = "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>";
        }

        # URL handling
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\cb";
          action = "<pipe-message> urlscan<Enter>";
        }
        {
          map = [
            "attach"
            "compose"
          ];
          key = "\\cb";
          action = "<pipe-entry> urlscan<Enter>";
        }

        # Save all attachments
        {
          map = [
            "index"
            "pager"
          ];
          key = "E";
          action = "<pipe-message>ripmime -i - -d ~/Downloads && rm ~/Downloads/textfile*";
        }

        # Search with notmuch
        {
          map = [ "index" ];
          key = "\\\\";
          action = "<vfolder-from-query>";
        }

        # Save to folder
        {
          map = [
            "index"
            "pager"
          ];
          key = "S";
          action = "<save-message>?<enter>";
        }
      ];

      settings = {
        sort = "threads";
        sort_aux = "reverse-last-date-received";
        mark_old = "no";
        wait_key = "no";
        mail_check_stats = "yes";
        query_command = "\"echo '' && notmuch address %s\"";
        query_format = "\"%4c %t %-70.70a %-70.70n %?e?(%e)?\"";
        sort_alias = "unsorted";
        sendmail = "\"${pkgs.msmtp}/bin/msmtp -a will\"";
      };

      sidebar = {
        enable = true;
        width = 30;
        format = "%D%?F? [%F]?%* %?N?%N/?%S";
        shortPath = true;
      };

      extraConfig = ''
        # Don't require confirmation to move mail
        unset confirmappend

        # Mailcap configuration for attachment handling
        set mailcap_path = "~/.mailcap"

        # Notmuch configuration
        set nm_default_uri = "notmuch:///home/will/.mail"

        # GPG integration
        set crypt_use_gpgme = yes
        set crypt_autosign = yes
        set crypt_verify_sig = yes
        set crypt_replysign = yes
        set crypt_replyencrypt = yes
        set crypt_replysignencrypted = yes

        # HTML email handling
        auto_view text/html
        alternative_order text/plain text/enriched text/html

        # Lists
        subscribe bitcoin-dev bitcoin-dev@lists.linuxfoundation.org
        subscribe lightning-dev lightning-dev@lists.linuxfoundation.org

        # Catppuccin Macchiato theme
        set color_directcolor = yes
        color normal      "#cad3f5" "#24273a"  # text on base
        color attachment  "#8aadf4" "#24273a"  # blue on base
        color bold        "#cad3f5" "#24273a"  # text on base
        color error       "#ed8796" "#24273a"  # red on base
        color hdrdefault  "#c6a0f6" "#24273a"  # mauve on base
        color indicator   "#cad3f5" "#363a4f"  # text on surface0
        color markers     "#494d64" "#24273a"  # surface1 on base
        color normal      "#cad3f5" "#24273a"  # text on base
        color quoted      "#8aadf4" "#24273a"  # blue
        color quoted1     "#ed8796" "#24273a"  # red
        color quoted2     "#a6da95" "#24273a"  # green
        color quoted3     "#f5a97f" "#24273a"  # peach
        color quoted4     "#c6a0f6" "#24273a"  # mauve
        color quoted6     "#a6da95" "#24273a"  # green
        color search      "#24273a" "#f5a97f"  # base on peach
        color signature   "#a6da95" "#24273a"  # green on base
        color status      "#a6da95" "#363a4f"  # green on surface0
        color tilde       "#494d64" "#24273a"  # surface1 on base
        color tree        "#a6da95" "#24273a"  # green on base
        color underline   "#cad3f5" "#363a4f"  # text on surface0

        color sidebar_divider    "#8aadf4" "#24273a"  # blue on base
        color sidebar_new        "#a6da95" "#24273a"  # green on base
        color sidebar_unread     "#8bd5ca" "#24273a"  # teal on base

        color index "#a6da95" "#24273a" ~N  # green on base (new)
        color index "#8bd5ca" "#24273a" ~O  # teal on base (old)
        color index "#8aadf4" "#24273a" ~P  # blue on base (from me)
        color index "#eed49f" "#24273a" ~F  # yellow on base (flagged)
        color index "#c6a0f6" "#24273a" ~Q  # mauve on base (replied)
        color index "#ed8796" "#24273a" ~=  # red on base (duplicate)
        color index "#24273a" "#cad3f5" ~T  # base on text (tagged)
        color index "#24273a" "#ed8796" ~D  # base on red (deleted)

        color header "#eed49f" "#24273a" "^(To:|From:)"  # yellow
        color header "#a6da95" "#24273a" "^Subject:"     # green
        color header "#8bd5ca" "#24273a" "^X-Spam-Status:"  # teal
        color header "#8bd5ca" "#24273a" "^Received:"    # teal

        # URLs and hostnames
        color body "#a6da95" "#24273a" "[a-z]{3,255}://[[:graph:]]*"
        color body "#a6da95" "#24273a" "([-[:alnum:]]+\\.)+([0-9]{1,3}|[-[:alpha:]]+)/[[:graph:]]*"
        color body "#a6da95" "#24273a" "([-[:alnum:]]+\\.){2,255}[-[:alpha:]]{2,10}"

        # IP addresses
        color body "#a6da95" "#24273a" "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"

        # Mail addresses and mailto URLs
        color body "#f5a97f" "#24273a" "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
        color body "#f5a97f" "#24273a" "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"

        # Smileys and formatting
        color body "#24273a" "#eed49f" "[;:]-*[)>(<lt;|]"  # base on yellow
        color body "#cad3f5" "#24273a" "\\*[- A-Za-z]+\\*"

        # GPG/PGP messages
        color body "#eed49f" "#24273a" "^-.*PGP.*-*"
        color body "#a6da95" "#24273a" "^gpg: Good signature from"
        color body "#ed8796" "#24273a" "^gpg: Can't.*$"
        color body "#eed49f" "#24273a" "^gpg: WARNING:.*$"
        color body "#ed8796" "#24273a" "^gpg: BAD signature from"
        color body "#ed8796" "#24273a" "^gpg: Note: This key has expired!"

        # Compose view
        color compose header            "#cad3f5" "#24273a"  # text on base
        color compose security_encrypt  "#c6a0f6" "#24273a"  # mauve on base
        color compose security_sign     "#8aadf4" "#24273a"  # blue on base
        color compose security_both     "#a6da95" "#24273a"  # green on base
        color compose security_none     "#f5a97f" "#24273a"  # peach on base
      '';
    };

    # Desktop-specific GPG conf
    gpg.scdaemonSettings = {
      reader-port = "Yubikey";
      disable-ccid = true;
    };

    # Desktop-specific git aliases
    git.settings.alias = {
      # Linux-specific clipboard command
      ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | wl-copy; }; f";
    };
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
  };

  # DankMaterialShell configuration for niri
  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = false; # Disabled - we have custom keybinds in modules/desktop-niri.nix
      enableSpawn = false; # Disabled - we spawn via niri config in modules/desktop-niri.nix
    };
    # Optional features
    enableSystemMonitoring = true; # Requires dgop
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = false;
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      extensions.force = true;
      settings = {
        # Wayland support
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
        "layout.css.devPixelsPerPx" = 2.0;

        # Better integration
        "browser.display.use_system_colors" = true;
        "widget.disable-swipe-tracker" = false;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland support
    GDK_BACKEND = "wayland"; # Force GTK apps to use Wayland
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  xresources.properties = {
  };

  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  home.file.".mailcap" = {
    text = ''
      text/html; lynx -dump %s; nametemplate=%s.html; copiousoutput
      text/plain; nvim %s
      image/*; swayimg %s
      application/pdf; evince %s
    '';
  };

  sops.secrets.email_password = {
    sopsFile = ../secrets/will.yaml;
    path = "${config.home.homeDirectory}/.secrets/email_password";
  };

  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/.mail";
    accounts.will = {
      primary = true;
      address = "will@256k1.dev";
      userName = "will@256k1.dev";
      realName = "Will";
      passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.email_password.path}";

      imap = {
        host = "imap.mailbox.org";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "smtp.mailbox.org";
        port = 465;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };

      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = [ "*" ];
      };

      msmtp.enable = true;
      notmuch.enable = true;
      neomutt = {
        enable = true;
        sendMailCommand = "${pkgs.msmtp}/bin/msmtp -a will";
        extraConfig = ''
          # Named mailboxes
          named-mailboxes "Inbox" =Inbox
          named-mailboxes "Archive" =Archive
          named-mailboxes "OXTU" =Inbox/OXTU
          named-mailboxes "Sent" =Sent
          named-mailboxes "Trash" =Trash
          named-mailboxes "bitcoin-dev" =Inbox/bitcoin-dev
          named-mailboxes "Maed House" =Inbox/Maed\ House
          named-mailboxes "Archive 2021" =Archive/2021
          named-mailboxes "Archive 2022" =Archive/2022
          named-mailboxes "Archive 2023" =Archive/2023
          named-mailboxes "Archive 2024" =Archive/2024
          named-mailboxes "Azores 2023" =Inbox/2023\ Azores
          named-mailboxes "Barcelona 2023" =Inbox/2023\ Barcelona
          named-mailboxes "Chaincode" =Chaincode
          named-mailboxes "Costa Rica 2023" =Inbox/2023\ Costa\ Rica
          named-mailboxes "Delving" =Inbox/Delving
          named-mailboxes "Drafts" =Drafts
          named-mailboxes "Free Rangers" =Inbox/Free\ rangers
          named-mailboxes "Github" =Inbox/Github
          named-mailboxes "Junk" =Junk
          named-mailboxes "Oakfield Road" =Inbox/6\ Oakfield\ Road
          named-mailboxes "Optech" =Inbox/Optech
        '';
      };

      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        onNotify = "${pkgs.isync}/bin/mbsync --quiet will:INBOX";
      };
    };
  };

  services.imapnotify.enable = true;

  sops = {
    defaultSopsFile = ../secrets/will.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/png" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/png" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
    };
  };

  xdg.configFile."mimeapps.list".force = true;

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program /run/current-system/sw/bin/pinentry-gnome3
    '';
  };
}
