{ inputs, ... }:
{
  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    {
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        notmuch = {
          enable = true;
          hooks.preNew = "mbsync --all";
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
            {
              map = [ "index" ];
              key = "X";
              action = "vfolder-from-query";
            }
          ];
          macros = [
            {
              map = [
                "index"
                "pager"
              ];
              key = "A";
              action = "<save-message>=Archive<enter>";
            }
            {
              map = [ "index" ];
              key = "O";
              action = "<shell-escape>mbsync -a<enter>";
            }
            {
              map = [ "index" ];
              key = "\\Cr";
              action = "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>";
            }
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
            {
              map = [
                "index"
                "pager"
              ];
              key = "E";
              action = "<pipe-message>ripmime -i - -d ~/Downloads && rm ~/Downloads/textfile*";
            }
            {
              map = [ "index" ];
              key = "\\\\";
              action = "<vfolder-from-query>";
            }
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
            unset confirmappend
            set mailcap_path = "~/.mailcap"
            set nm_default_uri = "notmuch://${config.home.homeDirectory}/.mail"
            set crypt_use_gpgme = yes
            set crypt_autosign = yes
            set crypt_verify_sig = yes
            set crypt_replysign = yes
            set crypt_replyencrypt = yes
            set crypt_replysignencrypted = yes
            set pgp_default_key = "67AA5B46E7AF78053167FE343B8F814A784218F8"
            set pgp_sign_as = "67AA5B46E7AF78053167FE343B8F814A784218F8"
            auto_view text/html
            alternative_order text/plain text/enriched text/html
            subscribe bitcoin-dev bitcoin-dev@lists.linuxfoundation.org
            subscribe lightning-dev lightning-dev@lists.linuxfoundation.org
            set color_directcolor = yes
            color normal      "#cad3f5" "#24273a"
            color attachment  "#8aadf4" "#24273a"
            color bold        "#cad3f5" "#24273a"
            color error       "#ed8796" "#24273a"
            color hdrdefault  "#c6a0f6" "#24273a"
            color indicator   "#cad3f5" "#363a4f"
            color markers     "#494d64" "#24273a"
            color normal      "#cad3f5" "#24273a"
            color quoted      "#8aadf4" "#24273a"
            color quoted1     "#ed8796" "#24273a"
            color quoted2     "#a6da95" "#24273a"
            color quoted3     "#f5a97f" "#24273a"
            color quoted4     "#c6a0f6" "#24273a"
            color quoted6     "#a6da95" "#24273a"
            color search      "#24273a" "#f5a97f"
            color signature   "#a6da95" "#24273a"
            color status      "#a6da95" "#363a4f"
            color tilde       "#494d64" "#24273a"
            color tree        "#a6da95" "#24273a"
            color underline   "#cad3f5" "#363a4f"
            color sidebar_divider    "#8aadf4" "#24273a"
            color sidebar_new        "#a6da95" "#24273a"
            color sidebar_unread     "#8bd5ca" "#24273a"
            color index "#a6da95" "#24273a" ~N
            color index "#8bd5ca" "#24273a" ~O
            color index "#8aadf4" "#24273a" ~P
            color index "#eed49f" "#24273a" ~F
            color index "#c6a0f6" "#24273a" ~Q
            color index "#ed8796" "#24273a" ~=
            color index "#24273a" "#cad3f5" ~T
            color index "#24273a" "#ed8796" ~D
            color header "#eed49f" "#24273a" "^(To:|From:)"
            color header "#a6da95" "#24273a" "^Subject:"
            color header "#8bd5ca" "#24273a" "^X-Spam-Status:"
            color header "#8bd5ca" "#24273a" "^Received:"
            color body "#a6da95" "#24273a" "[a-z]{3,255}://[[:graph:]]*"
            color body "#a6da95" "#24273a" "([-[:alnum:]]+\\.)+([0-9]{1,3}|[-[:alpha:]]+)/[[:graph:]]*"
            color body "#a6da95" "#24273a" "([-[:alnum:]]+\\.){2,255}[-[:alpha:]]{2,10}"
            color body "#a6da95" "#24273a" "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
            color body "#f5a97f" "#24273a" "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
            color body "#f5a97f" "#24273a" "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
            color body "#24273a" "#eed49f" "[;:]-*[)>(<lt;|]"
            color body "#cad3f5" "#24273a" "\\*[- A-Za-z]+\\*"
            color body "#eed49f" "#24273a" "^-.*PGP.*-*"
            color body "#a6da95" "#24273a" "^gpg: Good signature from"
            color body "#ed8796" "#24273a" "^gpg: Can't.*$"
            color body "#eed49f" "#24273a" "^gpg: WARNING:.*$"
            color body "#ed8796" "#24273a" "^gpg: BAD signature from"
            color body "#ed8796" "#24273a" "^gpg: Note: This key has expired!"
            color compose header            "#cad3f5" "#24273a"
            color compose security_encrypt  "#c6a0f6" "#24273a"
            color compose security_sign     "#8aadf4" "#24273a"
            color compose security_both     "#a6da95" "#24273a"
            color compose security_none     "#f5a97f" "#24273a"
          '';
        };
      };

      home.file.".mailcap".text = ''
        text/html; lynx -dump %s; nametemplate=%s.html; copiousoutput
        text/plain; nvim %s
        image/*; swayimg %s
        application/pdf; evince %s
      '';

      sops.secrets.email_password = {
        sopsFile = "${inputs.self}/secrets/will.yaml";
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
    };
}
