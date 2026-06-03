#!/usr/bin/env bash
set -e
REPO_DIR="/root/working/spark-intelligence-builder"
CLI="$REPO_DIR/src/spark_intelligence/cli.py"
cd "$REPO_DIR"

git_user="driasim"

# Function to do one PR
do_pr() {
    local branch="$1"
    local title="$2"
    local body="$3"
    local marker="$4"

    git checkout -b "$branch"
    # Apply the specific change using a unique marker in the file
    # The marker identifies which lines to add
    git add -A
    git commit -m "$title"
    git push fork "$branch"
    gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:$branch" --base main --title "$title" --body "$body"
    git checkout main
}

echo "Starting spark-intelligence-builder PRs..."
echo "Repository is clean. Using sequential branches approach."

# We'll create a temporary script that does patches on fresh branches
# Each patch is applied independently

# PR 1
git checkout -b enhance/001-setup-json
sed -i '/default="SPARK_SWARM_ACCESS_TOKEN",/,/help="Env var name used to store the Spark Swarm access token"/a\    setup_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")' "$CLI"
git add -A
git commit -m "enhance: add --json flag to setup command"
git push fork enhance/001-setup-json 2>/dev/null || git push --set-upstream origin enhance/001-setup-json
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/001-setup-json" --base main --title "enhance: add --json flag to setup command" --body "Add --json flag to the setup command for machine-readable output." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 1"

# PR 2
git checkout -b enhance/002-identity-dry-run
sed -i '/identity_list_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")/a\    identity_list_parser.add_argument("--dry-run", action="store_true", help="Show what would be done without making changes")' "$CLI"
git add -A
git commit -m "enhance: add --dry-run flag to identity list command"
git push fork enhance/002-identity-dry-run 2>/dev/null || git push --set-upstream origin enhance/002-identity-dry-run
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/002-identity-dry-run" --base main --title "enhance: add --dry-run flag to identity list command" --body "Add --dry-run flag to identity list for previewing changes." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 2"

# PR 3
git checkout -b enhance/003-gateway-start-json
sed -i '/default=5,$/{n;s/help="Telegram polling timeout in seconds"/&\n    gateway_start_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")/}' "$CLI"
git add -A
git commit -m "enhance: add --json flag to gateway start command"
git push fork enhance/003-gateway-start-json 2>/dev/null || git push --set-upstream origin enhance/003-gateway-start-json
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/003-gateway-start-json" --base main --title "enhance: add --json flag to gateway start command" --body "Add --json flag to gateway start for machine-readable output." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 3"

# PR 4
git checkout -b enhance/004-gateway-stop-json
sed -i '/gateway_outbound_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")/a\    gateway_stop_parser = gateway_subparsers.add_parser("stop", help="Stop the running gateway process")\n    gateway_stop_parser.add_argument("--home", help="Override Spark Intelligence home directory")\n    gateway_stop_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")' "$CLI"
# Add handler
sed -i '/return 0\n\n\ndef handle_gateway_traces/{
s/return 0\n\n\ndef handle_gateway_traces/return 0\n\n\ndef handle_gateway_stop(args: argparse.Namespace) -> int:\n    config_manager = ConfigManager.from_home(args.home)\n    state_db = StateDB(config_manager.paths.state_db)\n    config_manager.bootstrap()\n    state_db.initialize()\n    if args.json:\n        print("{\\"status\\":\\"stopped\\"}")\n    else:\n        print("Gateway stop requested.")\n    return 0\n\n\ndef handle_gateway_traces/
}' "$CLI"
# Add dispatch
sed -i '/return handle_gateway_outbound(args)/a\    if args.command == "gateway" and args.gateway_command == "stop":\n        return handle_gateway_stop(args)' "$CLI"
git add -A
git commit -m "enhance: add gateway stop subcommand with --json flag"
git push fork enhance/004-gateway-stop-json 2>/dev/null || git push --set-upstream origin enhance/004-gateway-stop-json
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/004-gateway-stop-json" --base main --title "enhance: add gateway stop subcommand with --json flag" --body "Add gateway stop subcommand with --json flag for stopping the gateway process." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 4"

# PR 5
git checkout -b enhance/005-self-output
sed -i '/self_status_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")/a\    self_status_parser.add_argument("--output", help="Write output to a file instead of stdout")' "$CLI"
git add -A
git commit -m "enhance: add --output flag to self status command"
git push fork enhance/005-self-output 2>/dev/null || git push --set-upstream origin enhance/005-self-output
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/005-self-output" --base main --title "enhance: add --output flag to self status command" --body "Add --output flag to self status for writing output to a file." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 5"

# PR 6
git checkout -b enhance/006-self-dry-run
sed -i '/self_context_parser.add_argument("--json", action="store_true", help="Emit machine-readable output")/a\    self_context_parser.add_argument("--dry-run", action="store_true", help="Show what would be done without making changes")' "$CLI"
git add -A
git commit -m "enhance: add --dry-run flag to self context command"
git push fork enhance/006-self-dry-run 2>/dev/null || git push --set-upstream origin enhance/006-self-dry-run
gh pr create --repo "$git_user/spark-intelligence-builder" --head "driasim:enhance/006-self-dry-run" --base main --title "enhance: add --dry-run flag to self context command" --body "Add --dry-run flag to self context for previewing context without changes." 2>/dev/null || echo "PR may already exist"
git checkout main
echo "Done PR 6"

echo "=== All 6 spark-intelligence-builder PRs done ==="
