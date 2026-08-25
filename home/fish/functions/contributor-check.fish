function contributor-check --argument-names username --description 'Summarize bitcoin/bitcoin contributor activity'
    set all false
    if test (count $argv) -eq 2; and test $argv[2] = --all
        set all true
    else if test (count $argv) -ne 1
        echo "Usage: contributor-check <github-username> [--all]" >&2
        return 1
    end

    set date_filter
    if test $all = false
        set date (date --date='6 months ago' +%Y-%m-%d)
        set date_filter --created ">=$date"
    end

    echo "Pull requests authored by $username"
    gh search prs --repo bitcoin/bitcoin --author $username $date_filter

    echo ""
    echo "Issues authored by $username"
    gh search issues --repo bitcoin/bitcoin --author $username $date_filter

    echo ""
    echo "Issues and pull requests commented on by $username"
    gh search issues --repo bitcoin/bitcoin --commenter $username --include-prs $date_filter

    echo ""
    echo "Pull requests reviewed by $username"
    gh search prs --repo bitcoin/bitcoin --reviewed-by $username $date_filter
end
