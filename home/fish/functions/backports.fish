function backports --argument-names base_branch
    if test -z "$base_branch"
        echo "Usage: backports <base-branch>"
        return 1
    end

    set -l outfile (mktemp /tmp/backports.XXXXXX)

    function __git_color
        git -c color.ui=always $argv
    end

    echo "Fetching upstream..."
    git fetch upstream --tags --prune

    set merge_base (git merge-base HEAD $base_branch)
    set commits (git rev-list $merge_base..HEAD)

    # Group commits by PR and collect metadata
    set -l pr_groups
    set -l non_backports

    for commit in $commits
        set github_pull (git show -s --format=%B $commit | grep 'Github-Pull:' | cut -d ' ' -f 2 | sed 's/#//')
        set rebased_from (git show -s --format=%B $commit | grep 'Rebased-From:' | cut -d ' ' -f 2)

        if test -n "$rebased_from"
            # It's a backport
            if test -n "$github_pull"
                set pr_key "pr_$github_pull"
            else
                set pr_key "single_$commit"
            end

            if not contains $pr_key $pr_groups
                set pr_groups $pr_groups $pr_key
                set -g $pr_key"_commits"
                set -g $pr_key"_originals"
            end

            # Add to this PR group (in reverse order since we're iterating from HEAD)
            set -l commits_var $pr_key"_commits"
            set -l originals_var $pr_key"_originals"
            set $commits_var $commit $$commits_var
            set $originals_var $rebased_from $$originals_var
        else
            # Non-backport commit
            set non_backports $non_backports $commit
        end
    end

    # Process PR groups
    for pr_group in $pr_groups
        set commits_var $pr_group"_commits"
        set originals_var $pr_group"_originals"
        set pr_commits $$commits_var
        set pr_originals $$originals_var

        echo "" >> $outfile
        echo "═══════════════════════════════════════════════════════════════" >> $outfile
        echo "Reviewing $pr_group" >> $outfile
        echo "═══════════════════════════════════════════════════════════════" >> $outfile

        # Check for missing commits from original PR
        set github_pull (echo $pr_group | sed 's/pr_//')
        if test "$github_pull" != "$pr_group"
            set original_pr_commits (gh pr view $github_pull --json commits -q '.commits[].oid')
            for orig_commit in $original_pr_commits
                if not contains $orig_commit $pr_originals
                    echo "" >> $outfile
                    echo "⚠️  Missing commit from original PR #$github_pull:" >> $outfile
                    __git_color log --oneline -1 $orig_commit >> $outfile
                    echo "" >> $outfile
                end
            end
        end

        if test (count $pr_commits) -eq 1
            # Single commit - use single commit range
            set original $pr_originals[1]
            set backport $pr_commits[1]
            __git_color range-diff $original^..$original $backport^..$backport >> $outfile 2>&1
        else
            # Multiple commits - use full range
            set first_original $pr_originals[1]
            set last_original $pr_originals[-1]
            set first_backport $pr_commits[1]
            set last_backport $pr_commits[-1]
            __git_color range-diff $first_original^..$last_original $first_backport^..$last_backport >> $outfile 2>&1
        end

        # Check release notes
        set github_pull (echo $pr_group | sed 's/pr_//')
        if test "$github_pull" != "$pr_group" -a -f doc/release-notes.md
            echo "" >> $outfile
            if grep -q "#$github_pull" doc/release-notes.md
                echo "✅ PR #$github_pull in release notes" >> $outfile
            else
                echo "❌ PR #$github_pull missing from release notes" >> $outfile
            end
        end
    end

    # Process non-backport commits
    for commit in $non_backports
        echo "" >> $outfile
        echo "═══════════════════════════════════════════════════════════════" >> $outfile
        echo "Non-backport: $commit" >> $outfile
        echo "═══════════════════════════════════════════════════════════════" >> $outfile

        if command -v difft >/dev/null
            GIT_EXTERNAL_DIFF=difft __git_color show --ext-diff $commit >> $outfile 2>&1
        else
            __git_color show $commit >> $outfile 2>&1
        end
    end

    # Cleanup global variables
    for pr_group in $pr_groups
        set -e $pr_group"_commits"
        set -e $pr_group"_originals"
    end
    functions -e __git_color

    echo "Output written to $outfile"
    less -R $outfile
end
