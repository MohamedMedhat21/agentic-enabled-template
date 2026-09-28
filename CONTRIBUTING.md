# Contributing

Thanks for improving the agentic repository template. These rules keep the kit consistent across tools, skeletons and the worked example.

## Workflow

1. Fork the repository and create a branch in your fork.
2. Make one focused change per pull request.
3. Open a pull request against `main` and fill in the checklist below.

## Commit messages

Use a short imperative subject line, for example `Add gap-review wrapper` or `Fix robocopy flags in Quick install`. Add a body only when the reason for the change is not obvious.

## Where to make changes

| Change                   | Rule                                                                                                                                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prompt text              | Edit the shared file in [core/docs/agents/prompts/](core/docs/agents/prompts/). Do not put prompt logic in the Copilot or Claude Code wrappers.                       |
| New prompt               | Add the shared file plus both wrappers: `core/.github/prompts/<name>.prompt.md` and `core/.claude/commands/<name>.md`. Follow the format of the existing wrappers.    |
| Skeletons                | Reflect every structural change in [skeletons/](skeletons/) in [examples/berthplan/](examples/berthplan/), so the example stays a filled-in version of the skeleton.  |
| Add-on slots             | When adding or renaming a slot, update [add-ons/README.md](add-ons/README.md), the markers in [skeletons/](skeletons/), and the example company profile's `slots.md`. |
| Enforcement hooks        | Change [guard.ps1](add-ons/enforcement-hooks/.agents/hooks/guard.ps1) and [guard.sh](add-ons/enforcement-hooks/.agents/hooks/guard.sh) together so both behave alike. |
| Company-specific content | Keep it out of `core/` and `skeletons/`. It belongs in an add-on profile under [add-ons/](add-ons/). Do not add real project, customer or internal company details.   |

Also update [README.md](README.md) when a change affects installation, the playbook, tool support or the readiness checklist.

## Verification

Describe in the pull request how you verified the change:

- [ ] Ran each changed or new prompt in at least one agent tool (name the tool).
- [ ] Tried the [Quick install](README.md#quick-install) copy on a scratch repository and confirmed the expected files appear.
- [ ] For hook changes: tried a blocked command (for example `git push`) and saw it refused, on each shell you changed.
- [ ] Applied the sync rules above that relate to the change.
