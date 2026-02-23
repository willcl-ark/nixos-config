function based-range-diff --description 'Range-diff two commits against a remote master base'
    argparse h/help -- $argv
    or return

    if set -ql _flag_help
        echo "based-range-diff [-h|--help] <remote> <old-commit> <new-commit>"
        echo "  Fetches remote master, then shows range-diff of both commits against it"
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

    echo "git range-diff $remote/master $old_commit $new_commit"
    git range-diff $remote/master $old_commit $new_commit
end
