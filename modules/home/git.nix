{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        attributes = [ "* merge=mergiraf" ];
        signing = {
          key = "0xCE6EC49945C17EA6";
          signByDefault = true;
        };
        settings = {
          user = {
            name = "will";
            email = "will@256k1.dev";
          };
          url."git@github.com:".insteadOf = "https://github.com/";
          init.defaultBranch = "master";
          diff.algorithm = "patience";
          merge.conflictStyle = "diff3";
          merge.mergiraf.name = "mergiraf";
          merge.mergiraf.driver = "${pkgs.mergiraf}/bin/mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
          rerere.enabled = true;
          rerere.autoUpdate = true;
          pull.rebase = true;
          push.autoSetupRemote = true;
          core.editor = "nvim";
          gpg.program = "${pkgs.gnupg}/bin/gpg2";
          alias = {
            a = "add .";
            b = "branch";
            cp = "cherry-pick";
            cpcont = "cherry-pick --continue";
            d = "difftool";
            ds = "diff --staged";
            f = "fetch --all --prune";
            lo = "log --oneline -n 40";
            m = "mergetool";
            po = "push origin";
            pu = "push upstream";
            pushf = "push --force-with-lease";
            r = "rebase";
            ra = "rebase --abort";
            rcont = "rebase --continue";
            rd = "range-diff";
            rem = "remote";
            rh = "reset --hard";
            s = "status";
            co = "checkout";
            cob = "checkout -b";
            un = "reset HEAD";
            amend = "commit --amend";
            cm = "commit";
            com = "commit -m";
            fix = "commit --amend --no-edit";
            coauth = "!f() { git shortlog --summary --numbered --email --all | grep \"$1\" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*/Co-authored-by: /'; }; f";
            files = "!f() { git diff-tree --no-commit-id --name-only -r HEAD; }; f";
            fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
            last = "log -1 HEAD";
            pr = "!f() { git fetch $1 pull/$2/head:pr-$2 && git switch pr-$2; }; f";
            pru = "!f() { git fetch --update-head-ok -f $1 pull/$2/head:pr-$2 && [ \"$(git branch --show-current)\" = \"pr-$2\" ] && git reset --hard HEAD || true; }; f";
            rb = "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch); }; f";
            rba = "!f() { default_branch=$(git symbolic-ref refs/remotes/upstream/HEAD | sed 's@^refs/remotes/upstream/@@'); git rebase -i $(git merge-base HEAD upstream/$default_branch) --autosquash; }; f";
            review = "!f() { git -c sequence.editor='sed -i s/pick/edit/' rebase -i $(git merge-base master HEAD); }; f";
            show-pr = "!f() { git log --merges --ancestry-path --oneline $1..HEAD | tail -n 1; }; f";
            tags = "!sh -c 'git for-each-ref --sort=-taggerdate --format=\"%(refname:lstrip=2)\" refs/tags | fzf | xargs git checkout'";
            ddiff = "-c diff.external=${pkgs.difftastic}/bin/difft diff";
            dlog = "-c diff.external=${pkgs.difftastic}/bin/difft log --ext-diff";
            dshow = "-c diff.external=${pkgs.difftastic}/bin/difft show --ext-diff";
          };
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          line-numbers = true;
          conflict-style = "zdiff3";
        };
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
        };
      };
    };
}
