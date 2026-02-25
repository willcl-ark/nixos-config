function wt --description 'Worktree manager'
    if test (count $argv) -eq 0
        __wt_usage
        return 1
    end

    switch $argv[1]
        case pr
            __wt_pr $argv[2..]
        case rm
            __wt_rm $argv[2..]
        case mv
            __wt_mv $argv[2..]
        case ls
            __wt_ls $argv[2..]
        case -h --help
            __wt_usage
        case '*'
            echo "wt: unknown subcommand '$argv[1]'"
            __wt_usage
            return 1
    end
end

function __wt_usage
    echo "Usage: wt <command> [args]"
    echo
    echo "Commands:"
    echo "  pr <remote> <pr-num>  Fetch a PR and check it out in a worktree"
    echo "  rm                    Remove a worktree (current, or choose from list)"
    echo "  mv                    Move current branch into a worktree"
    echo "  ls                    List worktrees"
end

function __wt_pr
    if test (count $argv) -lt 2
        echo "Usage: wt pr <remote> <pr-number>"
        return 1
    end

    set -l remote $argv[1]
    set -l pr_num $argv[2]
    set -l branch_name "pr-$pr_num"
    set -l worktree_path "../worktrees/$branch_name"

    if test -d $worktree_path
        cd $worktree_path
        set -l old_head (git rev-parse HEAD)
        git fetch $remote "pull/$pr_num/head"
        or return 1
        set -l new_head (git rev-parse FETCH_HEAD)
        if test "$old_head" != "$new_head"
            based-range-diff $remote $old_head $new_head
            git reset --hard $new_head
        end
        return 0
    end

    git fetch $remote "+pull/$pr_num/head:$branch_name"
    or return 1

    mkdir -p ../worktrees
    git worktree add $worktree_path $branch_name
    or return 1

    cd $worktree_path
end

function __wt_rm
    set -l worktrees (git worktree list --porcelain | string match --regex '(?<=^worktree ).+')
    set -l main_worktree $worktrees[1]

    set -l current_dir (pwd -P)
    set -l in_worktree ""
    for w in $worktrees[2..]
        if string match -q "$w*" $current_dir
            set in_worktree $w
            break
        end
    end

    if test -n "$in_worktree"
        set -l target $in_worktree
        cd $main_worktree
        __wt_force_remove $target
        return $status
    end

    if test (count $worktrees) -le 1
        echo "No worktrees to remove."
        return 1
    end

    echo "Select a worktree to remove:"
    for i in (seq 2 (count $worktrees))
        echo "  $i) $worktrees[$i]"
    end

    read -P "Choice: " choice
    if not string match -qr '^\d+$' $choice; or test $choice -lt 2; or test $choice -gt (count $worktrees)
        echo "Invalid selection."
        return 1
    end

    set -l target $worktrees[$choice]
    __wt_force_remove $target
end

function __wt_force_remove
    set -l target $argv[1]
    if git worktree remove $target 2>/dev/null
        echo "Removed worktree: $target"
        return 0
    end

    echo "Worktree has modified or untracked files:"
    git -C $target status --short
    echo
    read -P "Force remove? [y/N] " confirm
    if string match -qi y $confirm
        git worktree remove --force $target
        or return 1
        echo "Removed worktree: $target"
        return 0
    end

    echo "Aborted."
    return 1
end

function __wt_mv
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

function __wt_ls
    git worktree list $argv
end
