# Add-on: enforcement hooks

Instruction files guide agents; they cannot stop a determined or confused one. This add-on adds a `PreToolUse` hook that runs before every agent tool call and blocks or escalates risky actions deterministically, in both GitHub Copilot (VS Code) and Claude Code.

## What it enforces

| Action                                                                 | Decision | Why                                                                  |
| ---------------------------------------------------------------------- | -------- | -------------------------------------------------------------------- |
| `git push` (any form)                                                  | Deny     | Pushing is left to the user                                          |
| `--no-verify`                                                          | Deny     | Commit and push hooks, such as secret scanning, must not be bypassed |
| `git reset --hard`                                                     | Deny     | Destroys uncommitted work                                            |
| `git clean -f...`                                                      | Deny     | Deletes untracked files                                              |
| `git rebase`, `git filter-branch`                                      | Ask      | Rewrites history                                                     |
| `git commit --amend`                                                   | Ask      | Rewrites the last commit, which may be published                     |
| `git branch -D`                                                        | Ask      | Force-deletes a branch                                               |
| `git tag <name>`                                                       | Ask      | Tags can trigger release pipelines                                   |
| `rm -rf`, `Remove-Item -Recurse`                                       | Ask      | Recursive deletion                                                   |
| Editing `.agents/hooks/`, `.github/hooks/` or `.claude/settings*.json` | Deny     | Agents must not weaken their own guardrails                          |

"Ask" shows the user a confirmation prompt; "Deny" blocks the call and tells the agent why. Everything else passes to the tool's normal permission flow. Adjust the lists at the top of each script.

## Files

| File                             | Used by                                                                         |
| -------------------------------- | ------------------------------------------------------------------------------- |
| `.agents/hooks/guard.ps1`        | Windows (both tools); PowerShell 5.1 or later                                   |
| `.agents/hooks/guard.sh`         | macOS, Linux, Git Bash (both tools); needs only bash, grep and sed              |
| `.github/hooks/agent-guard.json` | GitHub Copilot in VS Code; picks the script per platform                        |
| `.claude/settings.json`          | Claude Code on macOS, Linux or Windows with Git Bash                            |
| `.claude/settings.windows.json`  | Claude Code on Windows without Git Bash; rename it to `settings.json` to use it |

## Install

1. Copy `.agents/`, `.github/hooks/` and the `.claude/` file for your platform into the repository root. If the repository already has a `.claude/settings.json`, merge the `hooks` block into it instead of overwriting it.
2. On macOS and Linux, make the shell script executable: `chmod +x .agents/hooks/guard.sh`.
3. Make sure `*.sh` files are checked out with LF line endings: add `*.sh text eol=lf` to the repository's `.gitattributes`.
4. Add this line to the Guardrails section of `AGENTS.md`:
   `- Enforcement hooks in .agents/hooks/, .github/hooks/ and .claude/settings.json block risky commands. Do not edit, disable or work around them; ask the user.`
5. Restart the agent session so the hooks load. In Claude Code, accept the workspace trust dialog; check with `/hooks`.

## Test

Pipe sample hook input into the script and check the decision. On Windows:

```powershell
'{"tool_name":"Bash","tool_input":{"command":"git push"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .agents/hooks/guard.ps1
'{"tool_name":"Bash","tool_input":{"command":"git status"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File .agents/hooks/guard.ps1
```

On macOS or Linux:

```sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push"}}' | bash .agents/hooks/guard.sh
```

The first command prints a `deny` decision; `git status` prints nothing. Then ask the agent to run `git push --dry-run` and confirm that it is refused.

`-ExecutionPolicy Bypass` applies only to that one PowerShell process, so the local script can run without changing the machine's policy.

## Limitations

- The checks are pattern matches on the tool input. They catch honest mistakes, not a deliberate attempt to hide a command (for example through variables or encoded strings). Keep server-side protection as the real control: protected branches, required reviews and push rules on the Git host.
- Tool names differ between tools and versions. The scripts cover Claude Code's `Bash`, `PowerShell`, `Edit`, `Write`, `MultiEdit` and `NotebookEdit`, and Copilot's `run_in_terminal`, `create_file`, `replace_string_in_file`, `multi_replace_string_in_file`, `edit_notebook_file` and `apply_patch`. Add names if your tool version uses others.
- VS Code can also read hooks from `.claude/settings.json`. If both files are present, the guard may run twice in VS Code; the result is the same. If VS Code reports an error for the Claude-format file, keep only `.github/hooks/agent-guard.json` for Copilot users.
- If a hook script fails to start, both tools treat it as a non-blocking error and let the call through. After installing, run the test above once in each tool.
- Test status in this kit: `guard.ps1` was tested with 12 sample inputs for both tools' tool names. `guard.sh` has not been run yet; test it on macOS, Linux or Git Bash before relying on it.
