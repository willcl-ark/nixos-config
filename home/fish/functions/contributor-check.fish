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

    set review_comments_endpoint repos/bitcoin/bitcoin/pulls/comments?per_page=100
    if test $all = false
        set review_comments_endpoint "$review_comments_endpoint&since=$since_iso"
    end

    echo "Pull requests authored by $username"
    gh search prs --repo bitcoin/bitcoin --author $username $search_date --limit 1000

    echo ""
    echo "Issues authored by $username"
    gh search issues --repo bitcoin/bitcoin --author $username $search_date --limit 1000

    echo ""
    echo "Conversation comments by $username"
    set comment_query 'query($login: String!, $endCursor: String) {
        user(login: $login) {
            issueComments(first: 100, after: $endCursor, orderBy: {field: UPDATED_AT, direction: DESC}) {
                nodes {
                    createdAt
                    repository { nameWithOwner }
                    url
                }
                pageInfo { hasNextPage endCursor }
            }
        }
    }'
    set comment_filter '.data.user.issueComments.nodes[] | select(.repository.nameWithOwner == "bitcoin/bitcoin")'
    if test $all = false
        set comment_filter "$comment_filter | select(.createdAt >= \"$since_iso\")"
    end
    set comment_filter "$comment_filter | [.createdAt[0:10], .url] | @tsv"
    gh api graphql --paginate -f login=$username -f query="$comment_query" --jq $comment_filter

    echo ""
    echo "Inline pull request review comments by $username"
    set review_comment_filter ".[] | select(.user.login == \"$username\")"
    if test $all = false
        set review_comment_filter "$review_comment_filter | select(.created_at >= \"$since_iso\")"
        set review_query 'query($login: String!, $from: DateTime!, $to: DateTime!, $endCursor: String) {
            user(login: $login) {
                contributionsCollection(from: $from, to: $to) {
                    pullRequestReviewContributions(first: 100, after: $endCursor) {
                        nodes {
                            occurredAt
                            repository { nameWithOwner }
                            pullRequest { number url }
                            pullRequestReview { state }
                        }
                        pageInfo { hasNextPage endCursor }
                    }
                }
            }
        }'
        set now_iso (date -u +%Y-%m-%dT%H:%M:%SZ)
        set review_prs (gh api graphql --paginate -f login=$username -f from=$since_iso -f to=$now_iso -f query="$review_query" --jq '.data.user.contributionsCollection.pullRequestReviewContributions.nodes[] | select(.repository.nameWithOwner == "bitcoin/bitcoin") | .pullRequest.number')
        set review_comment_filter "$review_comment_filter | [.created_at[0:10], .html_url] | @tsv"
        for pr in $review_prs
            gh api --paginate "repos/bitcoin/bitcoin/pulls/$pr/comments?per_page=100&since=$since_iso" --jq $review_comment_filter
        end
    else
        set review_comments_endpoint "$review_comments_endpoint&sort=updated&direction=desc"
        set review_comment_filter "$review_comment_filter | [.created_at[0:10], .html_url] | @tsv"
        gh api --paginate $review_comments_endpoint --jq $review_comment_filter
    end

    echo ""
    echo "Pull request reviews submitted by $username"
    if test $all = false
        gh api graphql --paginate \
            -f login=$username -f from=$since_iso -f to=$now_iso \
            -f query="$review_query" \
            --jq '.data.user.contributionsCollection.pullRequestReviewContributions.nodes[] | select(.repository.nameWithOwner == "bitcoin/bitcoin") | [.occurredAt[0:10], .pullRequestReview.state, .pullRequest.url] | @tsv'
    else
        set review_filter ".[] | select(.user.login == \"$username\" and .submitted_at != null)"
        set review_filter "$review_filter | [.submitted_at[0:10], .state, .html_url] | @tsv"
        for pr in (gh search prs --repo bitcoin/bitcoin --reviewed-by $username --limit 1000 --json number --jq '.[].number')
            gh api --paginate "repos/bitcoin/bitcoin/pulls/$pr/reviews" --jq $review_filter
        end
    end
end
