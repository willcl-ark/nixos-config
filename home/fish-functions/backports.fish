function backports --argument-names base_branch
    if test -z "$base_branch"
        echo "Usage: backports <base-branch>"
        return 1
    end

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

        echo "=== Reviewing $pr_group ==="

        if test (count $pr_commits) -eq 1
            # Single commit - use single commit range
            set original $pr_originals[1]
            set backport $pr_commits[1]
            git range-diff $original^..$original $backport^..$backport
        else
            # Multiple commits - use full range
            set first_original $pr_originals[1]
            set last_original $pr_originals[-1]
            set first_backport $pr_commits[1]
            set last_backport $pr_commits[-1]
            git range-diff $first_original^..$last_original $first_backport^..$last_backport
        end

        # Check release notes
        set github_pull (echo $pr_group | sed 's/pr_//')
        if test "$github_pull" != "$pr_group" -a -f doc/release-notes.md
            if grep -q "#$github_pull" doc/release-notes.md
                echo "✓ PR #$github_pull is in release notes"
            else
                echo "⚠ PR #$github_pull NOT found in release notes"
            end
        end
        echo "==========================="

        read -P "Continue? (y/n) " -n 1 response
        if test "$response" != y -a "$response" != Y
            return 0
        end
        echo
    end

    # Process non-backport commits
    for commit in $non_backports
        echo "=== Non-backport: $commit ==="
        if command -v difft >/dev/null
            git -c diff.external=difft show --ext-diff $commit
        else
            git show $commit
        end

        read -P "Continue? (y/n) " -n 1 response
        if test "$response" != y -a "$response" != Y
            return 0
        end
        echo
    end

    # Cleanup global variables
    for pr_group in $pr_groups
        set -e $pr_group"_commits"
        set -e $pr_group"_originals"
    end
end

