# Review backport commits on the current branch against their originals.
#
# Usage: backports <base-branch>
#   e.g. backports upstream/31.x
#
# Scope: Only commits on HEAD that are NOT reachable from <base-branch>.
#   These are the commits unique to the current branch — i.e. the backport PR's
#   commits, not the entire release branch history.
#   Computed via: git rev-list <base-branch>..HEAD  (two-dot, not merge-base)
#
# For each commit with a "Rebased-From:" trailer, it's a backport. Commits
# sharing the same "Github-Pull:" trailer are grouped into one PR.
#
# Per PR group the function:
#   1. Fetches the original PR's commit list from GitHub (in parallel)
#   2. Warns about any original commits missing from the backport
#   3. Runs git range-diff between original and backported commits
#   4. Checks if the PR is mentioned in doc/release-notes.md
#
# Commits without "Rebased-From:" are shown as non-backport diffs.
#
# Github-Pull trailer formats handled:
#   #34805           -> bitcoin/bitcoin PR 34805
#   gui#899          -> bitcoin-core/gui PR 899
#   #gui901          -> bitcoin-core/gui PR 901
#   https://...      -> used as-is
function backports --argument-names base_branch
    if test -z "$base_branch"
        echo "Usage: backports <base-branch>"
        return 1
    end

    set -l outfile (mktemp /tmp/backports.XXXXXX)
    set -l divider "═══════════════════════════════════════════════════════════════"

    function __git_color
        git -c color.ui=always $argv
    end

    function __backports_section --argument-names outfile divider title
        echo "" >> $outfile
        echo $divider >> $outfile
        echo $title >> $outfile
        echo $divider >> $outfile
    end

    set -l remote (string split '/' -- $base_branch)[1]
    set -l branch (string join '/' -- (string split '/' -- $base_branch)[2..])
    echo "Fetching $base_branch..."
    git fetch $remote $branch:refs/remotes/$remote/$branch

    set commits (git rev-list $base_branch..HEAD)

    # Group commits by PR and collect metadata
    set -l pr_groups
    set -l pr_ids
    set -l non_backports

    for commit in $commits
        set -l message (git show -s --format=%B $commit)
        set -l raw_pull (
            string split \n -- $message \
            | string match -r '^Github-Pull:\s+\S+' \
            | string replace -r '^Github-Pull:\s+' ''
        )
        set -l github_pull ""
        if string match -qr '^https://' -- $raw_pull
            set github_pull $raw_pull
        else if string match -qr 'gui' -- $raw_pull
            set github_pull "https://github.com/bitcoin-core/gui/pull/"(string match -r '\d+' -- $raw_pull)
        else if test -n "$raw_pull"
            set github_pull (string replace -r '^#' '' -- $raw_pull)
        end
        set -l rebased_from (
            string split \n -- $message \
            | string match -r '^Rebased-From:\s+\S+' \
            | string replace -r '^Rebased-From:\s+' ''
        )

        if test -n "$rebased_from"
            # It's a backport — sanitize key for use as fish variable name
            set -l pr_key
            if test -n "$github_pull"
                set -l sanitized (string replace -ra '[^a-zA-Z0-9_]' '_' -- $github_pull)
                set pr_key "pr_$sanitized"
            else
                set pr_key "single_$commit"
            end

            if not contains $pr_key $pr_groups
                set pr_groups $pr_groups $pr_key
                set pr_ids $pr_ids "$github_pull"
                set -g $pr_key"_commits"
                set -g $pr_key"_originals"
            end

            # Add to this PR group (in reverse order since we're iterating from HEAD)
            set -l commits_var $pr_key"_commits"
            set -l originals_var $pr_key"_originals"
            set $commits_var $commit $$commits_var
            set $originals_var $rebased_from $$originals_var
        else
            set non_backports $non_backports $commit
        end
    end

    # Pre-fetch PR commit data in parallel
    set -l tmpdir (mktemp -d /tmp/backports_gh.XXXXXX)
    echo "Fetching commit data for "(count $pr_ids)" PRs..."
    for idx in (seq (count $pr_ids))
        if test -n "$pr_ids[$idx]"
            gh pr view $pr_ids[$idx] --json commits -q '.commits[].oid' >$tmpdir/$idx 2>/dev/null &
        end
    end
    wait

    # Process PR groups
    for idx in (seq (count $pr_groups))
        set pr_group $pr_groups[$idx]
        set pr_id $pr_ids[$idx]
        set commits_var $pr_group"_commits"
        set originals_var $pr_group"_originals"
        set pr_commits $$commits_var
        set pr_originals $$originals_var

        __backports_section $outfile $divider "Reviewing $pr_id"

        if test -n "$pr_id" -a -f $tmpdir/$idx
            set original_pr_commits (cat $tmpdir/$idx)
            for orig_commit in $original_pr_commits
                if not contains $orig_commit $pr_originals
                    echo "" >> $outfile
                    echo "⚠️  Missing commit from original PR $pr_id:" >> $outfile
                    __git_color log --oneline -1 $orig_commit >> $outfile
                    echo "" >> $outfile
                end
            end
        end

        if test (count $pr_commits) -eq 1
            set original $pr_originals[1]
            set backport $pr_commits[1]
            __git_color range-diff $original^..$original $backport^..$backport >> $outfile 2>&1
        else
            set first_original $pr_originals[1]
            set last_original $pr_originals[-1]
            set first_backport $pr_commits[1]
            set last_backport $pr_commits[-1]
            __git_color range-diff $first_original^..$last_original $first_backport^..$last_backport >> $outfile 2>&1
        end

        if test -n "$pr_id" -a -f doc/release-notes.md
            echo "" >> $outfile
            if grep -q "$pr_id" doc/release-notes.md
                echo "✅ PR $pr_id in release notes" >> $outfile
            else
                echo "❌ PR $pr_id missing from release notes" >> $outfile
            end
        end
    end

    # Process non-backport commits
    for commit in $non_backports
        __backports_section $outfile $divider "Non-backport: $commit"

        if command -v difft >/dev/null
            GIT_EXTERNAL_DIFF=difft __git_color show --ext-diff $commit >> $outfile 2>&1
        else
            __git_color show $commit >> $outfile 2>&1
        end
    end

    # Cleanup
    rm -rf $tmpdir
    for pr_group in $pr_groups
        set -e $pr_group"_commits"
        set -e $pr_group"_originals"
    end
    functions -e __git_color
    functions -e __backports_section

    echo "Output written to $outfile"
    less -R $outfile
end
