#!/usr/bin/env bash
# PreToolUse guard for coding agents (GitHub Copilot in VS Code and Claude Code).
# Reads the hook input JSON from stdin. Prints a deny or ask decision as JSON, or nothing to leave the call to the normal permission flow.
# Needs only bash, grep and sed; no jq.

raw=$(tr -d '\n\r')

decide() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$2"
  exit 0
}

has() { printf '%s' "$raw" | grep -Eq -- "$1"; }

tool_name=$(printf '%s' "$raw" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

case "$tool_name" in
  Bash|PowerShell|run_in_terminal)
    has 'git[[:space:]]+push([^[:alnum:]_-]|$)'        && decide deny 'Pushing is left to the user. Report the branch and commits instead.'
    has '--no-verify'                                   && decide deny 'Commit and push hooks must not be bypassed.'
    has 'git[[:space:]]+reset[[:space:]]+--hard'        && decide deny 'Hard resets can destroy work. Ask the user to run it.'
    has 'git[[:space:]]+clean[[:space:]]+-[A-Za-z]*f'   && decide deny 'git clean deletes untracked files. Ask the user to run it.'
    has 'git[[:space:]]+(rebase|filter-branch)'         && decide ask 'Rewriting history needs confirmation.'
    has 'git[[:space:]]+commit[^"]*--amend'             && decide ask 'Amending a commit needs confirmation.'
    has 'git[[:space:]]+branch[[:space:]]+(-D|--delete[[:space:]]+--force)' && decide ask 'Force-deleting a branch needs confirmation.'
    has 'git[[:space:]]+tag[[:space:]]+[^[:space:]"]'  && decide ask 'Creating or deleting tags can trigger pipelines.'
    has '(^|[^[:alnum:]])rm[[:space:]]+-[A-Za-z]*(r[A-Za-z]*f|f[A-Za-z]*r)' && decide ask 'Recursive deletion needs confirmation.'
    has 'Remove-Item[^"]*-Recurse'                      && decide ask 'Recursive deletion needs confirmation.'
    ;;
  Edit|Write|MultiEdit|NotebookEdit|create_file|replace_string_in_file|multi_replace_string_in_file|edit_notebook_file|apply_patch)
    paths=$(printf '%s' "$raw" | grep -Eo '"(file_path|filePath|path)"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:[[:space:]]*"\(.*\)"/\1/' | sed 's/\\\\/\//g')
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      if printf '%s' "$p" | grep -Eq '(^|/)(\.agents/+hooks/|\.claude/+settings[^/]*\.json$|\.github/+hooks/)'; then
        decide deny "Agent hook files and hook settings change only with the user's approval. Ask the user to edit them."
      fi
    done <<EOF
$paths
EOF
    ;;
esac

exit 0
