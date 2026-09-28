# Agentic repository template

A reusable kit that makes a code repository ready for AI coding agents: one shared instruction file (`AGENTS.md`), a user-story workflow with an approval gate and acceptance-criteria evidence, reusable prompts, optional enforcement hooks, and named add-on slots for company-specific rules.

The kit is stack-agnostic. The worked example in [examples/berthplan/](examples/berthplan/) uses a fictional Java/Spring Boot and Angular project.

## Quick install

1. Create a branch in the target repository and commit or stash unrelated changes.
2. Copy the kit's `core/` folder into the repository root. The commands below never overwrite existing files.

   PowerShell:

   ```powershell
   $kit  = "D:\agentic-repo-template"   # this kit
   $repo = "D:\path\to\your-repo"      # target repository
   robocopy "$kit\core" "$repo" /E /XC /XN /XO
   ```

   Bash (macOS, Linux, Git Bash):

   ```sh
   KIT=~/agentic-repo-template   # this kit
   REPO=~/code/your-repo         # target repository
   cp -Rn "$KIT/core/." "$REPO/"
   ```

   Robocopy exit codes 0 to 7 mean success; 1 means files were copied.

3. Optional: for skeleton mode, copy `skeletons/` the same way (replace `core` with `skeletons` in the command). For enforcement hooks, follow [add-ons/enforcement-hooks/README.md](add-ons/enforcement-hooks/README.md).
4. Check the result. The repository should now contain:

   ```
   docs/agents/prompts/bootstrap-repo.md, start-user-story.md, gap-review.md
   .github/prompts/bootstrap-repo.prompt.md, start-user-story.prompt.md, gap-review.prompt.md
   .claude/commands/bootstrap-repo.md, start-user-story.md, gap-review.md
   ```

5. Open the repository in your agent tool and run the bootstrap prompt:
   - GitHub Copilot in VS Code: `/bootstrap-repo` in Chat, agent mode.
   - Claude Code: `/bootstrap-repo`.
   - Codex, Cursor or other tools: paste the contents of `docs/agents/prompts/bootstrap-repo.md`.

The agent asks its setup questions, writes an audit and stops for your review before creating any agent file. The [Playbook](#playbook) below describes the whole flow.

## Contents

| Path                                       | Purpose                                                                                                                                    | Copy into the target repo?  |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- |
| [core/](core/)                             | Shared prompts in `docs/agents/prompts/`, plus thin wrappers for GitHub Copilot (`.github/prompts/`) and Claude Code (`.claude/commands/`) | Always                      |
| [skeletons/](skeletons/)                   | Fill-in versions of `AGENTS.md`, `CLAUDE.md`, `docs/setup.md` and `docs/plans/_template.md` with placeholders and add-on slots             | Only in skeleton mode       |
| [add-ons/](add-ons/)                       | Slot catalogue, an example company profile, and optional enforcement hooks                                                                 | Only the add-ons you choose |
| [examples/berthplan/](examples/berthplan/) | A filled-in reference for a fictional project                                                                                              | Never; read it for guidance |

## Two ways to bootstrap a repository

Both start the same way: copy [core/](core/) into the root of the target repository and run the **bootstrap-repo** prompt.

1. **Prompt mode (default).** The agent audits the repository, pauses for your review, and then writes `AGENTS.md`, `CLAUDE.md`, `docs/setup.md` and `docs/plans/_template.md` from what it found. Use this for most repositories.
2. **Skeleton mode.** Also copy [skeletons/](skeletons/) into the repository root. The agent (or you) fills in the placeholders instead of writing the files from scratch. Use this when you want a fixed structure across many repositories or want to fill some sections by hand.

The bootstrap prompt asks which mode you use; it detects skeleton mode when `AGENTS.md` still contains `{{` placeholders.

## Playbook

1. **Prepare.** Work on a new branch of the target repository. Commit or stash unrelated changes first.
2. **Copy files.** Copy [core/](core/) into the repository root, as in [Quick install](#quick-install). In skeleton mode, also copy [skeletons/](skeletons/). Copy any add-on you want (see [add-ons/README.md](add-ons/README.md)).
3. **Run bootstrap-repo.**
   - GitHub Copilot in VS Code: type `/bootstrap-repo` in Chat (agent mode).
   - Claude Code: type `/bootstrap-repo`.
   - Other tools: paste the contents of `docs/agents/prompts/bootstrap-repo.md`.
4. **Answer the setup questions.** Mode, add-on profile, tools in use, base branch, issue-key format, and tracker permissions.
5. **Review the audit.** The agent writes `.agent-bootstrap-audit.md` and stops. Correct anything wrong before it continues.
6. **Review the generated files.** The agent writes the instruction files, fills the add-on slots and stops again. Nothing is committed.
7. **Run gap-review.** The agent compares the files with the audit requirements and the repository, reports gaps and waits before editing.
8. **Verify commands.** Ask the agent to run the cheapest documented checks (for example lint and one unit test class) and record which commands actually passed.
9. **Commit.** Review the diff yourself, delete `.agent-bootstrap-audit.md` (or keep it out of the commit) and commit.
10. **Maintain.** Re-run gap-review after large refactors, tooling changes or when agents repeat the same mistake.

## Tool support

| Tool                      | Reads `AGENTS.md`                                                                                         | Reusable prompts in this kit                 | Hooks add-on            |
| ------------------------- | --------------------------------------------------------------------------------------------------------- | -------------------------------------------- | ----------------------- |
| GitHub Copilot in VS Code | Yes                                                                                                       | `.github/prompts/*.prompt.md`                | `.github/hooks/*.json`  |
| Claude Code               | Yes, when no `CLAUDE.md` exists; the kit ships a `CLAUDE.md` that imports `@AGENTS.md` so it always loads | `.claude/commands/*.md`                      | `.claude/settings.json` |
| OpenAI Codex              | Yes                                                                                                       | Paste the prompt from `docs/agents/prompts/` | Not covered             |
| Cursor                    | Yes                                                                                                       | Paste the prompt from `docs/agents/prompts/` | Not covered             |

Notes:

- Keep `AGENTS.md` as the single source of instructions. Do not add `.github/copilot-instructions.md` as well; VS Code would load both and duplicate the instructions.
- The prompt text lives once in `docs/agents/prompts/`. The Copilot and Claude Code files are wrappers that point to it, so edit the shared file, not the wrappers.
- Instruction files guide agents but do not enforce anything. Use the [enforcement hooks](add-ons/enforcement-hooks/) for rules that must hold, such as never pushing.

## Add-on slots

Company-specific content sits between named markers so a profile can be applied or swapped later without rewriting the core:

```markdown
<!-- slot:vcs-flow -->

...content for this slot...

<!-- /slot:vcs-flow -->
```

The slots are `work-items`, `design-docs`, `vcs-flow`, `package-registry`, `secret-scanning`, `onboarding` and `compliance`. [add-ons/README.md](add-ons/README.md) describes each slot, its generic default and how to apply a profile. Keep the markers after bootstrapping; they cost a few tokens and make the next profile change a small edit.

## Readiness checklist

A repository is agent-ready when each item has been verified, not assumed:

- [ ] `AGENTS.md` exists at the root, contains no `{{` placeholders, and every command in it was either run successfully or is marked as not verified.
- [ ] `CLAUDE.md` imports `@AGENTS.md` (only needed when Claude Code is used).
- [ ] The architecture and layering rules match the code and any lint rules that enforce them.
- [ ] Guardrails list generated files, migration history, vendored code and lockfiles that agents must not edit.
- [ ] Secrets policy is explicit, and a secret scanner runs before commits (or its absence is recorded as a gap).
- [ ] The user-story workflow names the story source, the approval gate, the plan location and the acceptance-criteria evidence table.
- [ ] `docs/plans/_template.md` exists and matches the workflow.
- [ ] `docs/setup.md` covers first-time setup that depends on the repository, and links out for company onboarding.
- [ ] Every chosen add-on slot is filled; unused slots keep their generic default.
- [ ] Documentation references list design docs with a "known drift from code" column, and drift was reported to the doc owners.
- [ ] The reusable prompts run in each tool the team uses.
- [ ] If the hooks add-on is installed, a blocked command (for example `git push`) was tried and was refused.
- [ ] The bootstrap audit file is not committed.

## Writing good instructions

- Code and configuration are the source of truth. Instructions describe them and point to them; they do not replace them.
- Prefer rules an agent can check ("run `npm run lint`") over wishes ("write clean code").
- Link to READMEs and design docs instead of copying them. Copies drift.
- Keep always-loaded files short. Claude Code recommends under about 200 lines per instruction file; move long procedures into prompts when a file grows beyond that.
- When an agent repeats a mistake, add one precise rule instead of a paragraph.

## Contributing

Contributions are welcome through a fork and pull request to `main`. See [CONTRIBUTING.md](CONTRIBUTING.md) for commit style, sync rules between `core/`, `skeletons/`, `add-ons/` and the example, and the verification checklist.
