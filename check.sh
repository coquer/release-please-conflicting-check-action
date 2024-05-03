set -euo pipefail
pending_prs=$(gh pr list --repo "$REPO" --label "autorelease: pending" --state open --json number --jq '.[].number')
need_rebase=""

if [[ -n "$pending_prs" ]]; then
    for pr_num in $pending_prs; do
        echo "Checking pr: $pr_num"
        mergeable=$(gh pr view --repo "$REPO" "$pr_num" --json mergeable --jq '.mergeable')
        echo "mergeable status: $mergeable"
        if [[ "$mergeable" != "MERGEABLE" ]]; then
            echo "pr: $pr_num is not MERGEABLE."
            echo "removing 'autorelease: pending' label from pr: $pr_num"
            gh pr edit --repo "$REPO" "$pr_num" --remove-label "autorelease: pending"
            need_rebase=true
        fi
    done
else
    echo "No pending PRs found."
    exit 0
fi

if [[ -n "$need_rebase" ]]; then
    echo "not MERGEABLE status PRs found."
    echo "need_rebase=$need_rebase"
    echo "need_rebase=$need_rebase" >> "$GITHUB_OUTPUT"
else
    echo "All pending PRs are MERGEABLE."
fi
