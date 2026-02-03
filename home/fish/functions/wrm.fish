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
        git worktree remove $target
        or return 1
        echo "Removed worktree: $target"
        return 0
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
    git worktree remove $target
    or return 1
    echo "Removed worktree: $target"
end
