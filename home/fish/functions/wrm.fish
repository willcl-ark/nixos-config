function wrm --description 'Remove a git worktree (current, or choose from list)'
    set -l worktrees (git worktree list --porcelain | string match --regex '(?<=^worktree ).+')
    set -l main_worktree $worktrees[1]

    set -l current_dir (pwd -P)
    set -l in_worktree ""
    for wt in $worktrees[2..]
        if string match -q "$wt*" $current_dir
            set in_worktree $wt
            break
        end
    end

    if test -n "$in_worktree"
        set -l target $in_worktree
        cd $main_worktree
        __wrm_remove $target
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
    __wrm_remove $target
end

function __wrm_remove
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
