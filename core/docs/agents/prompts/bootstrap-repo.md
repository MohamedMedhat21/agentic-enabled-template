# Bootstrap this repository for coding agents

You are onboarding into this repository as a senior engineer. Your job is to make it ready for AI coding agents by creating or filling `AGENTS.md`, `CLAUDE.md`, `docs/setup.md` and `docs/plans/_template.md`, grounded only in what you verify in the repository and its linked documentation.

Work in the phases below. Do not start a phase until the previous one is complete and, where stated, the user has approved it. Do not commit, push, or delete files at any point.

## Rules for the whole task

- Verify rather than guess. Every command, path, version and rule you write must come from a file you read or a command you ran. When you cannot verify something, mark it "not verified" or ask.
- Code and configuration are the source of truth. Design documents describe intent; when they disagree with the code, follow the code and record the drift.
- Never write credentials, tokens or personal data into any file, command or chat message. Refer to environment variable names only.
- Do not change application code, build files, lockfiles, CI configuration or existing documentation other than the files this task creates, unless the user asks.
- If a new question comes up in any phase, stop the affected work, ask, and wait for the answer. Do not guess and continue.

## Phase 0: Setup questions

Ask these in one batch, using a question tool if one is available:

1. **Mode:** prompt mode (write the files from the audit) or skeleton mode (fill the placeholder files already in the repository)? If `AGENTS.md` exists and contains `{{`, propose skeleton mode.
2. **Add-on profile:** generic defaults, the example company profile in `add-ons/company-atlassian-gitlab-artifactory/` (if copied), or a custom profile the user describes.
3. **Tools:** which agents the team uses (GitHub Copilot, Claude Code, Codex, Cursor, other).
4. **Work items:** where user stories come from, the issue-key format, and whether the agent may comment on or change issues.
5. **Git:** the base branch for new work, branch naming, commit-message format, and whether the agent may commit locally.
6. **Plans:** confirm that story plans live in `docs/plans/` and are committed as the first commit of a story branch, or name another location.
7. **Hooks:** whether to install the enforcement-hooks add-on.

## Phase 1: Discovery audit

Inspect the repository with file reads and read-only commands. Cover:

1. **Stack and runtimes:** languages and versions, package managers, frameworks, core dependencies. Read manifests and wrapper files; do not assume.
2. **Commands:** the exact commands for installing dependencies, building, running locally, unit tests, running one test, integration and end-to-end tests, linting, formatting and type checking. Note where each comes from (README, manifest, CI file). Run only cheap, read-only checks such as version commands; do not install dependencies, start services or run full test suites without asking.
3. **Architecture:** top-level layout, layering and boundaries, where business logic and data access live, and any lint or build rules that enforce boundaries.
4. **Conventions:** error handling, logging, configuration and environment variables, naming of files and tests, formatting configuration.
5. **Pain points:** broken or misleading scripts, missing configuration, files agents must never edit (generated output, migration history, vendored code, lockfiles), and anything that prints or stores secrets.
6. **External documentation:** if tools for the team's tracker or wiki are available, read the design pages, architecture decisions and setup guides the user points to, and recent epics for domain terms. Record each page's purpose and any drift from the code. If no such tool is available, ask the user for the relevant pages or excerpts.

Write the findings to `.agent-bootstrap-audit.md` at the repository root with exactly these headings:

- `# 1. Tech stack and dependencies`
- `# 2. Commands and where they come from`
- `# 3. Architecture and code organization`
- `# 4. Conventions and patterns`
- `# 5. Guardrails (files and actions agents must avoid)`
- `# 6. External documentation and drift`
- `# 7. Open questions`
- `# 8. Plan for the agent files`

Then reply with a three-sentence summary, say the audit is ready for review, and stop. Continue only after the user confirms or corrects the audit.

## Phase 2: Write the agent files

Apply the approved audit and the Phase 0 answers.

### Skeleton mode

Fill every `{{...}}` placeholder in `AGENTS.md`, `CLAUDE.md`, `docs/setup.md` and `docs/plans/_template.md`. Delete a section only when it truly does not apply, and say so in your reply. No `{{` may remain.

### Prompt mode

Create `AGENTS.md` at the repository root with these sections, in this order, including only content you verified:

1. Title and a precedence note: code and configuration win over documentation; report mismatches.
2. **Project context:** what the product is, who runs it, and deployment constraints that affect design (for example offline operation).
3. **Domain terms:** a table of project terms verified in code or docs, and an instruction to ask about unknown terms.
4. **Tech stack:** a table of runtimes, frameworks and test tools, with a pointer to the files that define versions and a rule against unapproved dependencies.
5. **Scope and setup:** independent projects, where to run commands, which README covers what, and credential handling by environment variable name.
6. **Build and run commands:** one code block with the verified commands per project, then **Formatting** and **Known tooling gaps** subsections.
7. **Project structure:** a short annotated tree.
8. **Architecture:** layering and boundary rules per area, including what lint enforces.
9. **Coding rules:** General, Naming and configuration, one subsection per major area, and Security and logging.
10. **Testing requirements:** test levels, what to mock, no skipped or focused tests, independence, not changing tests to make them pass.
11. **Verification:** the nearest-test-first commands to run per area, and a rule to report which commands actually ran.
12. **Git workflow:** base branch, branch and commit naming, review flow, and forbidden actions (push, force-push, history rewrites, bypassing hooks) unless explicitly asked.
13. **Agent workflow rules:** read docs before changing an area, stay in scope, ask when ambiguous, ask all open questions before implementing and wait for answers, stop and ask when a question comes up mid-implementation, keep docs in step, report rather than work around problems, verify.
14. **Working on a user story:** the eight phases below, adapted to the answers from Phase 0.
15. **Guardrails:** generated output, migration history, vendored code, lockfiles, secrets.
16. **Definition of done:** a checklist that includes the story plan and acceptance-criteria evidence.
17. **Documentation references:** a table of page, use, and known drift from code.

The user-story section must contain these phases, each with an exit condition:

1. **Intake:** read the story from its source, restate acceptance criteria as `AC-1`, `AC-2`, ..., ask every open question.
2. **Discovery:** read the affected code, tests and docs; flag anything needing approval.
3. **Plan (approval gate):** write `docs/plans/<ISSUE-KEY>-<slug>.md` from `docs/plans/_template.md`, including a test plan that maps every acceptance criterion to a test; stop until the user approves.
4. **Branch:** update the base branch, create the story branch, and commit the plan first.
5. **Implement:** follow the plan's steps in layer order, write tests with each step, run the nearest tests, tick the step, commit locally; if a question comes up, stop that step, ask, and record the answer in the plan.
6. **Verify:** run the Verification commands and walk through the Definition of done.
7. **Validate acceptance criteria:** fill an evidence table (AC, evidence, exact command, result). A criterion that cannot be automated is marked "Needs manual check" with the check described; it never counts as met, but it does not block completion.
8. **Hand-off:** report changes, commits, the evidence table, commands and results, blocked gates, stale docs and follow-ups; offer a tracker comment and post it only after approval; leave pushing to the user.

Also create:

- `CLAUDE.md`, only if the team uses Claude Code, containing a one-line note and `@AGENTS.md` on its own line.
- `docs/plans/_template.md` with: source, base and story branch, status, summary, acceptance criteria, open questions, affected areas by layer, contract/schema/configuration changes, test plan table, implementation-step checklist, risks and out of scope, deviations, evidence table, manual checks.
- `docs/setup.md` with the first-time setup steps that depend on this repository (prerequisites, secret-scanning hook, per-project toolchain, credentials by variable name, how to start and test) and a link to company onboarding for accounts and licenses.
- One link to `AGENTS.md` and `docs/setup.md` from the root README, if the user agrees.

### Add-on slots

For each slot below, wrap its content in `<!-- slot:<name> -->` and `<!-- /slot:<name> -->` markers. Use the chosen profile's text when one was selected; otherwise write the generic default from `add-ons/README.md` (if present) adapted to the audit.

| Slot               | Location                                   |
| ------------------ | ------------------------------------------ |
| `work-items`       | AGENTS.md, Working on a user story, Intake |
| `design-docs`      | AGENTS.md, Documentation references        |
| `vcs-flow`         | AGENTS.md, Git workflow                    |
| `package-registry` | AGENTS.md, Scope and setup; docs/setup.md  |
| `secret-scanning`  | AGENTS.md, Git workflow; docs/setup.md     |
| `onboarding`       | docs/setup.md, introduction                |
| `compliance`       | AGENTS.md, Security and logging            |

### Hooks

If the user chose the enforcement-hooks add-on, follow `add-ons/enforcement-hooks/README.md` (if copied) and add a Guardrails line saying agents must not edit the hook files.

When Phase 2 is done, list the files you created or changed, state that nothing was committed, and stop.

## Phase 3: Gap review

Run the steps in `docs/agents/prompts/gap-review.md` and report before changing anything.

## Phase 4: Command check

With the user's agreement, run the cheapest documented checks (for example lint and one unit test class per project). Record in `AGENTS.md` any command that failed or could not run, and report the exact commands and results. Do not start full stacks, run credential-dependent suites or install dependencies without asking.
