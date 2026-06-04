function contributor-check --argument-names username --description 'Summarize bitcoin/bitcoin contributor activity'
    if test (count $argv) -ne 1
        echo "Usage: contributor-check <github-username>" >&2
        return 1
    end

    echo "Pull requests authored by $username"
    gh search prs --repo bitcoin/bitcoin --author $username

    echo ""
    echo "Issues authored by $username"
    gh search issues --repo bitcoin/bitcoin --author $username

    echo ""
    echo "Issues and pull requests commented on by $username"
    gh search issues --repo bitcoin/bitcoin --commenter $username --include-prs

    echo ""
    echo "Pull requests reviewed by $username"
    gh search prs --repo bitcoin/bitcoin --reviewed-by $username
end
