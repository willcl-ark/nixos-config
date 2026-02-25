function wt --description 'Move current branch into a worktree'
    argparse h/help -- $argv
    or return

    if set -ql _flag_help
        echo "wt [-h|--help]"
        echo "  Moves the current branch into a ../worktrees/<branch> worktree"
        return 0
    end

    set -l branch (git branch --show-current)
    if test -z "$branch"
        echo "Not on a named branch"
        return 1
    end

    set -l default_branch (git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | string replace 'origin/' '')
    if test -z "$default_branch"
        set default_branch master
    end

    if test "$branch" = "$default_branch"
        echo "Already on default branch ($default_branch)"
        return 1
    end

    set -l worktree_path "../worktrees/$branch"

    if test -d "$worktree_path"
        echo "Worktree already exists at $worktree_path"
        cd $worktree_path
        return 0
    end

    git switch $default_branch
    or return 1

    mkdir -p ../worktrees
    git worktree add $worktree_path $branch
    or return 1

    cd $worktree_path
end
