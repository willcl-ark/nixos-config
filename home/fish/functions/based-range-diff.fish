function based-range-diff --description 'Range-diff two commits against their merge-bases with master'
    argparse h/help -- $argv
    or return

    if set -ql _flag_help
        echo "based-range-diff [-h|--help] <remote> <old-commit> <new-commit>"
        echo "  Fetches remote master, then shows range-diff of both commits against their merge-base with master"
        return 0
    end

    if test (count $argv) -lt 3
        echo "Usage: based-range-diff <remote> <old-commit> <new-commit>"
        return 1
    end

    set -l remote $argv[1]
    set -l old_commit $argv[2]
    set -l new_commit $argv[3]

    git fetch $remote master:refs/remotes/$remote/master

    set -l old_base (git merge-base $remote/master $old_commit)
    set -l new_base (git merge-base $remote/master $new_commit)
    echo "git range-diff $old_base..$old_commit $new_base..$new_commit"
    git range-diff "$old_base..$old_commit" "$new_base..$new_commit"
end
