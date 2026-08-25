function contributor-check --argument-names username --description 'Summarize bitcoin/bitcoin contributor activity'
    set all false
    if test (count $argv) -eq 2; and test $argv[2] = --all
        set all true
    else if test (count $argv) -ne 1
        echo "Usage: contributor-check <github-username> [--all]" >&2
        return 1
    end

    set search_date
    set since_iso
    if test $all = false
        set since (date --date='6 months ago' +%Y-%m-%d)
        set since_iso "$since"T00:00:00Z
        set search_date --created ">=$since"
    end

    set comments_endpoint repos/bitcoin/bitcoin/issues/comments?per_page=100
    set review_comments_endpoint repos/bitcoin/bitcoin/pulls/comments?per_page=100
    if test $all = false
        set comments_endpoint "$comments_endpoint&since=$since_iso"
        set review_comments_endpoint "$review_comments_endpoint&since=$since_iso"
    end

    echo "Pull requests authored by $username"
    gh search prs --repo bitcoin/bitcoin --author $username $search_date --limit 1000

    echo ""
    echo "Issues authored by $username"
    gh search issues --repo bitcoin/bitcoin --author $username $search_date --limit 1000

    echo ""
    echo "Conversation comments by $username"
    set comment_filter ".[] | select(.user.login == \"$username\")"
    if test $all = false
        set comment_filter "$comment_filter | select(.created_at >= \"$since_iso\")"
    end
    set comment_filter "$comment_filter | [.created_at[0:10], .html_url] | @tsv"
    gh api --paginate $comments_endpoint --jq $comment_filter

    echo ""
    echo "Inline pull request review comments by $username"
    gh api --paginate $review_comments_endpoint --jq $comment_filter

    echo ""
    echo "Pull request reviews submitted by $username"
    set review_filter ".[] | select(.user.login == \"$username\" and .submitted_at != null)"
    if test $all = false
        set review_filter "$review_filter | select(.submitted_at >= \"$since_iso\")"
    end
    set review_filter "$review_filter | [.submitted_at[0:10], .state, .html_url] | @tsv"
    for pr in (gh search prs --repo bitcoin/bitcoin --reviewed-by $username --limit 1000 --json number --jq '.[].number')
        gh api --paginate "repos/bitcoin/bitcoin/pulls/$pr/reviews" --jq $review_filter
    end
end
