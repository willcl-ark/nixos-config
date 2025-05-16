{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.email;
in {
  options.roles.email = {
    enable = mkEnableOption "Email client role";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # libnotify
      lynx # For viewing HTML emails in neomutt
      notmuch-addrlookup
      ripmime # For extracting attachments
      urlscan
    ];

    # Create mailcap file
    home.file.".mailcap".text = ''
      text/html; lynx -dump %s; nametemplate=%s.html; copiousoutput
      image/*; swayimg %s
      application/pdf; zathura %s
    '';

    sops.secrets.email_password = {
      sopsFile = ../../secrets/will.yaml;
      path = "${config.home.homeDirectory}/.secrets/email_password";
    };

    # Unified email account configuration
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

        neomutt = {
          enable = true;
        };

        imapnotify = {
          enable = true;
          boxes = ["Inbox"];
          onNotify = "${pkgs.isync}/bin/mbsync --quiet will:INBOX";
          # onNotifyPost = ''
          #   ${pkgs.libnotify}/bin/notify-send "New mail arrived for will@256k1.dev"
          # '';
        };
      };
    };

    # Enable and configure email programs
    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.notmuch = {
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

    services.imapnotify.enable = true;

    programs.neomutt = {
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
        query_command = "\"notmuch-addrlookup --format=mutt '%s'\"";
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
        # named-mailboxes "Santorini" =Santorini

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
  };
}
