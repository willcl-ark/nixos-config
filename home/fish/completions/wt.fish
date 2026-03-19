complete -c wt -f
complete -c wt -n __fish_use_subcommand -a new -d 'Create a new branch worktree from upstream/master'
complete -c wt -n __fish_use_subcommand -a pr -d 'Fetch a PR into a worktree'
complete -c wt -n __fish_use_subcommand -a rm -d 'Remove a worktree'
complete -c wt -n __fish_use_subcommand -a mv -d 'Move current branch into a worktree'
complete -c wt -n __fish_use_subcommand -a ls -d 'List worktrees'
complete -c wt -n __fish_use_subcommand -a clean -d 'Remove build/ and guix* from all worktrees'
