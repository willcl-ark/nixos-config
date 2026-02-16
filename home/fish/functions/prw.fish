function prw --description 'Fetch a PR and check it out in a new worktree'
    argparse h/help -- $argv
    or return

    if set -ql _flag_help
        echo "prw [-h|--help] <remote> <pr-number>"
        echo "  Fetches a PR from the remote and creates a worktree for it"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: prw <remote> <pr-number>"
        return 1
    end

    set -l remote $argv[1]
    set -l pr_num $argv[2]
    set -l branch_name "pr-$pr_num"
    set -l worktree_path "../worktrees/$branch_name"

    if test -d $worktree_path
        cd $worktree_path
        set -l old_head (git rev-parse HEAD)
        git fetch $remote master "pull/$pr_num/head"
        or return 1
        set -l new_head (git rev-parse FETCH_HEAD)
        if test "$old_head" != "$new_head"
            echo "git range-diff (git merge-base $remote/master $old_head)..$old_head (git merge-base $remote/master $new_head)..$new_head"
            git range-diff (git merge-base $remote/master $old_head)..$old_head (git merge-base $remote/master $new_head)..$new_head
            git reset --hard FETCH_HEAD
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
