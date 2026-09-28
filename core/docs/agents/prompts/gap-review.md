# Gap review of the agent files

Check whether this repository's agent files are complete, correct and consistent with the code. Report first; do not edit anything until the user says which fixes to apply.

## Inputs

- `AGENTS.md`, `CLAUDE.md` (if present), `docs/setup.md`, `docs/plans/_template.md`, the READMEs, and `docs/agents/prompts/`.
- `.agent-bootstrap-audit.md` if it still exists.
- The design pages listed under **Documentation references**, if a tool can read them.

## Checks

1. **Placeholders:** no `{{` remains in `AGENTS.md`, `CLAUDE.md`, `docs/setup.md` or `docs/plans/_template.md`.
2. **Commands:** every command in `AGENTS.md` exists in a manifest, script or CI file. Flag commands that reference missing scripts or configurations.
3. **Versions and tools:** the tech-stack table matches the manifests and wrapper files.
4. **Paths:** every path and file named in the agent files exists.
5. **Architecture:** the layering rules match the code and any lint or build rules that enforce them. Flag rules the code already breaks.
6. **Guardrails:** generated output, migration history, vendored code, lockfiles and secret-printing scripts are covered.
7. **Workflow:** the user-story section has all eight phases with exit conditions, and `docs/plans/_template.md` matches it.
8. **Slots:** each `<!-- slot:... -->` marker has a matching closing marker and non-empty content.
9. **Tool files:** `CLAUDE.md` imports `@AGENTS.md`; each wrapper in `.github/prompts/` and `.claude/commands/` points to an existing prompt in `docs/agents/prompts/`; there is no `.github/copilot-instructions.md` duplicating `AGENTS.md`.
10. **Documentation drift:** for each design page, whether its "known drift" note is still accurate.
11. **Length:** flag instruction files that have grown long enough to hurt adherence (roughly more than 300 lines), and suggest what to move into prompts or linked docs.
12. **Audit coverage:** if the audit file exists, every finding in it is reflected in the agent files or listed as a deliberate omission.

## Report

Reply with a table of findings (check, status, evidence with file and line, proposed fix), followed by the fixes you recommend in priority order. Mark each finding as a gap, an inaccuracy, or stale documentation. Then stop and ask which fixes to apply.
