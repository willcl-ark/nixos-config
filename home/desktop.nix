{
  config,
  lib,
  pkgs,
  ...
}: {
  # Desktop configuration

  home.username = "will";
  home.homeDirectory = "/home/will";

  # Import common config and programs
  imports = [
    ./common.nix
    ./programs/tmux.nix
    # TODO: revert
    # Temporarily disable home-manager fish config to use system fish with existing dotfiles
    # ./programs/fish.nix
    ./programs/ghostty.nix
  ];

  # Desktop-specific applications
  home.packages = with pkgs; [
    # Desktop GUI apps
    bitwarden
    cider-2
    evince
    firefox
    keet
    kew
    ksnip
    mullvad
    museeks
    networkmanagerapplet
    pwvucontrol
    signal-desktop
    telegram-desktop
    tor-browser
    vlc
    nzbget

    # Kubernetes tools (desktop-specific)
    kubectl
    k9s
    helm
    k3d

    # Messaging
    weechat
    nicotine-plus

    # i3 specific
    dunst
    gnome-keyring
    dmenu
  ];

  # Scripts for custom keybinds
  home.file.".local/bin/gh-issue-open.sh" = {
    text = ''
      #!/usr/bin/env bash
      issue=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu -p "Bitcoin Issue #")
      [ -n "$issue" ] && ${pkgs.firefox}/bin/firefox --new-tab "https://github.com/bitcoin/bitcoin/issues/$issue"
    '';
    executable = true;
  };

  # Programs configuration
  programs = {
    # Development tools
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

    # i3status-rust for i3
    i3status-rust = {
      enable = true;
      bars = {
        default = {
          blocks = [
            {
              block = "disk_space";
              path = "/";
              info_type = "available";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "memory";
              format = " $icon $mem_used_percents ";
              format_alt = " $icon $swap_used_percents ";
            }
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "load";
              interval = 1;
              format = " $icon $1m ";
            }
            {
              block = "sound";
            }
            {
              block = "net";
              format = " $icon {$signal_strength $ssid $frequency|Wired connection} ";
              format_alt = " $icon {$signal_strength $ssid $frequency|Wired connection} via $device ";
            }
            {
              block = "time";
              interval = 60;
              format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
          settings = {
            theme = {
              theme = "ctp-macchiato";
            };
            icons = {
              icons = "awesome4";
            };
          };
        };
      };
    };

    # Email programs
    mbsync.enable = true;
    msmtp.enable = true;
    notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync --all";
      };
      new = {
        tags = ["unread" "inbox"];
        ignore = [".mbsyncstate" ".uidvalidity"];
      };
      search.excludeTags = ["deleted" "spam"];
      maildir.synchronizeFlags = true;
    };
    neomutt = {
      enable = true;
      binds = [
        # Basic navigation
        {
          map = ["index" "pager"];
          key = "\\Cd";
          action = "half-down";
        }
        {
          map = ["index" "pager"];
          key = "\\Cu";
          action = "half-up";
        }
        {
          map = ["index"];
          key = "g";
          action = "noop";
        }
        {
          map = ["index"];
          key = "gg";
          action = "first-entry";
        }
        {
          map = ["index"];
          key = "G";
          action = "last-entry";
        }
        {
          map = ["pager"];
          key = "g";
          action = "noop";
        }
        {
          map = ["pager"];
          key = "gg";
          action = "top";
        }
        {
          map = ["pager"];
          key = "G";
          action = "bottom";
        }

        # Additional vim-like bindings
        {
          map = ["index"];
          key = "j";
          action = "next-entry";
        }
        {
          map = ["index"];
          key = "k";
          action = "previous-entry";
        }
        {
          map = ["pager"];
          key = "j";
          action = "next-line";
        }
        {
          map = ["pager"];
          key = "k";
          action = "previous-line";
        }

        # Sidebar navigation
        {
          map = ["index" "pager"];
          key = "<down>";
          action = "sidebar-next";
        }
        {
          map = ["index" "pager"];
          key = "<up>";
          action = "sidebar-prev";
        }
        {
          map = ["index" "pager"];
          key = "<right>";
          action = "sidebar-open";
        }

        # Other useful bindings
        {
          map = ["index" "pager"];
          key = "@";
          action = "compose-to-sender";
        }
        {
          map = ["index" "pager"];
          key = "R";
          action = "group-reply";
        }
        {
          map = ["index"];
          key = "D";
          action = "purge-message";
        }
        {
          map = ["index"];
          key = "<tab>";
          action = "sync-mailbox";
        }
        {
          map = ["index"];
          key = "<space>";
          action = "collapse-thread";
        }
        {
          map = ["attach"];
          key = "<return>";
          action = "view-mailcap";
        }
        {
          map = ["editor"];
          key = "<tab>";
          action = "complete-query";
        }

        # Drafts
        {
          map = ["compose"];
          key = "P";
          action = "postpone-message";
        }
        {
          map = ["index"];
          key = "p";
          action = "recall-message";
        }

        # Notmuch search
        {
          map = ["index"];
          key = "X";
          action = "vfolder-from-query";
        }
      ];

      macros = [
        # Archive message
        {
          map = ["index" "pager"];
          key = "A";
          action = "<save-message>=Archive<enter>";
        }

        # Sync email
        {
          map = ["index"];
          key = "O";
          action = "<shell-escape>mbsync -a<enter>";
        }

        # Mark as read
        {
          map = ["index"];
          key = "\\Cr";
          action = "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>";
        }

        # URL handling
        {
          map = ["index" "pager"];
          key = "\\cb";
          action = "<pipe-message> urlscan<Enter>";
        }
        {
          map = ["attach" "compose"];
          key = "\\cb";
          action = "<pipe-entry> urlscan<Enter>";
        }

        # Save all attachments
        {
          map = ["index" "pager"];
          key = "E";
          action = "<pipe-message>ripmime -i - -d ~/Downloads && rm ~/Downloads/textfile*";
        }

        # Search with notmuch
        {
          map = ["index"];
          key = "\\\\";
          action = "<vfolder-from-query>";
        }

        # Save to folder
        {
          map = ["index" "pager"];
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

        # Notmuch configuration
        set nm_default_uri = "notmuch:///home/will/.mail"

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

        # Color scheme (gruvbox-material)
        # Colors for gruvbox-material dark theme
        set color_directcolor = yes
        color normal      "#d4be98" "#282828"
        color attachment  "#7daea3" "#282828"
        color bold        "#d4be98" "#282828"
        color error       "#ea6962" "#282828"
        color hdrdefault  "#927384" "#282828"
        color indicator   "#ddc7a1" "#504945" # index row highlight
        color markers     "#45403d" "#282828"
        color normal      "#d4be98" "#282828"
        color quoted      "#7daea3" "#282828" # blue
        color quoted1     "#ea6926" "#282828" # red
        color quoted2     "#89b482" "#282828" # aqua
        color quoted3     "#e78a4e" "#282828" # orange
        color quoted4     "#d3869b" "#282828" # purple
        color quoted6     "#89b482" "#282828" # aqua
        color search      "#282828" "#e78a4e"
        color signature   "#89b482" "#282828"
        color status      "#a9b665" "#282828"
        color tilde       "#45403d" "#282828"
        color tree        "#a9b665" "#282828"
        color underline   "#d4be98" "#32302f"

        color sidebar_divider    "#7daea3" "#282828"
        color sidebar_new        "#a9b665" "#282828"
        color sidebar_unread     "#89b482" "#282828"

        color index "#a9b665" "#282828" ~N
        color index "#89b482" "#282828" ~O
        color index "#7daea3" "#282828" ~P
        color index "#d8a657" "#282828" ~F
        color index "#d3869b" "#282828" ~Q
        color index "#ea6962" "#282828" ~=
        color index "#282828" "#d4be98" ~T
        color index "#282828" "#ea6962" ~D

        color header "#d8a657" "#282828" "^(To:|From:)"
        color header "#a9b665" "#282828" "^Subject:"
        color header "#89b482" "#282828" "^X-Spam-Status:"
        color header "#89b482" "#282828" "^Received:"

        # URLs and hostnames
        color body "#a9b665" "#282828" "[a-z]{3,255}://[[:graph:]]*"
        color body "#a9b665" "#282828" "([-[:alnum:]]+\\.)+([0-9]{1,3}|[-[:alpha:]]+)/[[:graph:]]*"
        color body "#a9b665" "#282828" "([-[:alnum:]]+\\.){2,255}[-[:alpha:]]{2,10}"

        # IP addresses
        color body "#a9b665" "#282828" "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"

        # Mail addresses and mailto URLs
        color body "#e78a4e" "#282828" "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
        color body "#e78a4e" "#282828" "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"

        # Smileys and formatting
        color body "#282828" "#d8a657" "[;:]-*[)>(<lt;|]"
        color body "#d4be98" "#282828" "\\*[- A-Za-z]+\\*"

        # GPG/PGP messages
        color body "#d8a657" "#282828" "^-.*PGP.*-*"
        color body "#a9b665" "#282828" "^gpg: Good signature from"
        color body "#ea6962" "#282828" "^gpg: Can't.*$"
        color body "#d8a657" "#282828" "^gpg: WARNING:.*$"
        color body "#ea6962" "#282828" "^gpg: BAD signature from"
        color body "#ea6962" "#282828" "^gpg: Note: This key has expired!"

        # Compose view
        color compose header            "#d4be98" "#282828"
        color compose security_encrypt  "#d3869b" "#282828"
        color compose security_sign     "#7daea3" "#282828"
        color compose security_both     "#a9b665" "#282828"
        color compose security_none     "#e78a4e" "#282828"
      '';
    };

    # Desktop-specific GPG configuration
    gpg.scdaemonSettings = {
      # Use a Yubikey reader
      reader-port = "Yubikey";
      disable-ccid = true;
    };

    # Desktop-specific git aliases
    git.aliases = {
      # Linux-specific clipboard command
      ack = "!f() { git rev-parse HEAD | tr -d '[:space:]' | xsel -b; }; f";
    };
  };

  # Services configuration
  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          # Don't wake up the display for notifications
          follow = "none";
          # Pause notifications when screen is locked
          idle_threshold = 0;
        };
      };
    };
  };

  # i3 configuration
  home.sessionVariables = {
    QT_SCALE_FACTOR = "2";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    XCURSOR_SIZE = "32";
  };

  xresources.properties = {
    "Xft.dpi" = 192;
    "Xcursor.size" = 32;
  };

  services.gnome-keyring = {
    enable = true;
    components = ["secrets" "ssh"];
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      fonts = {
        names = ["DejaVu Sans Mono"];
        size = 8.0;
      };
      terminal = "${pkgs.ghostty}/bin/ghostty";
      menu = "${pkgs.rofi}/bin/rofi -show drun";

      startup = [
        {
          command = "${pkgs.xorg.xsetroot}/bin/xsetroot -solid '#282828'";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.playerctl}/bin/playerctld daemon";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets";
          always = false;
          notification = false;
        }
        {
          command = "i3-msg workspace number 1";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.i3-auto-layout}/bin/i3-auto-layout";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.picom}/bin/picom -b";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.hsetroot}/bin/hsetroot -solid '#282828'";
          always = true;
          notification = false;
        }
      ];

      keybindings = let
        modifier = "Mod4";
      in {
        "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
        "${modifier}+Shift+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show run";
        "${modifier}+Return" = "exec --no-startup-id ${pkgs.ghostty}/bin/ghostty";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+m" = "split h";
        "${modifier}+v" = "split v";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'";
        "${modifier}+r" = "mode resize";
        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioStop" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl stop";
        "Shift+XF86Tools" = "exec --no-startup-id ${pkgs.ksnip}/bin/ksnip --rectarea";
        "XF86Tools" = "exec --no-startup-id ${pkgs.ksnip}/bin/ksnip --fullscreen";
        "${modifier}+x" = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl set-paused true && ${pkgs.i3lock}/bin/i3lock -c 000000 && sleep 1 && ${pkgs.xorg.xset}/bin/xset dpms force off && ${pkgs.dunst}/bin/dunstctl set-paused false";
        "${modifier}+g" = "exec --no-startup-id ~/.local/bin/gh-issue-open.sh";
      };

      modes = {
        resize = {
          "j" = "resize shrink width 10 px or 10 ppt";
          "k" = "resize grow height 10 px or 10 ppt";
          "l" = "resize shrink height 10 px or 10 ppt";
          "semicolon" = "resize grow width 10 px or 10 ppt";
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
          "${config.xsession.windowManager.i3.config.modifier}+r" = "mode default";
        };
      };

      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
        }
      ];

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "smart";
      };

      floating.modifier = "Mod4";
      workspaceAutoBackAndForth = true;

      colors = {
        focused = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
          indicator = "#2e9ef4";
          childBorder = "#285577";
        };
        focusedInactive = {
          border = "#333333";
          background = "#5f676a";
          text = "#ffffff";
          indicator = "#484e50";
          childBorder = "#5f676a";
        };
        unfocused = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292d2e";
          childBorder = "#222222";
        };
      };
    };
  };

  # Email configuration
  home.file.".mailcap" = {
    text = ''
      text/html; lynx -dump %s; nametemplate=%s.html; copiousoutput
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
        patterns = ["*"];
      };

      msmtp.enable = true;
      notmuch.enable = true;
      neomutt.enable = true;

      imapnotify = {
        enable = true;
        boxes = ["Inbox"];
        onNotify = "${pkgs.isync}/bin/mbsync --quiet will:INBOX";
      };
    };
  };

  services.imapnotify.enable = true;

  # User configuration
  sops = {
    defaultSopsFile = ../secrets/will.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  # XDG MIME applications
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
  };

  # Desktop-specific services
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program /run/current-system/sw/bin/pinentry-gnome3
    '';
  };
}
