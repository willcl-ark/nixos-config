function backport-review --description 'Check out a Bitcoin Core backport PR and review it with Codex'
    if test (count $argv) -ne 1
        echo 'Usage: backport-review <pr number>' >&2
        return 1
    end
    if not string match --quiet --regex '^[1-9][0-9]*$' -- "$argv[1]"
        echo 'Usage: backport-review <pr number>' >&2
        return 1
    end

    cd /home/will/src/core/bitcoin/worktrees/backports
    or return
    gh pr checkout "$argv[1]"
    or return
    codex --model gpt-6.1-sol --config 'model_reasoning_effort="low"' '$backport-check Review the checked-out PR in the current worktree. Infer its base branch from GitHub PR metadata.'
end
