# Project Guidelines

Read this file before changing code. Code and configuration in this repository are the source of truth for current behavior; the documents under [Documentation references](#documentation-references) explain design intent. Where they disagree, follow the code and report the mismatch rather than silently resolving it.

<!-- Skeleton: fill every placeholder in double curly braces, then delete this comment. Keep the slot markers so an add-on profile can be applied or swapped later. -->

## Project context

- {{PRODUCT: one or two sentences on what the product does and who uses it.}}
- {{RUNTIME CONTEXT: where it runs (cloud service, customer installation, device) and what that implies for startup, security and logging.}}
- {{DEPLOYMENT CONSTRAINTS: constraints that affect design, for example offline operation, supported platforms, multi-tenancy. Mark draft designs as drafts.}}
- Prefer a small, verified change over a broad, partly verified one.

## Domain terms

| Term     | Meaning in this repository                                     |
| -------- | -------------------------------------------------------------- |
| {{TERM}} | {{MEANING, with the package, module or domain where it lives}} |

This list covers terms verified in code and documentation. If you meet an unfamiliar term, ask instead of guessing its meaning.

## Tech stack

| Area                           | Current choice                                                   |
| ------------------------------ | ---------------------------------------------------------------- |
| Runtimes                       | {{language and runtime versions, package managers}}              |
| {{AREA, for example Backend}}  | {{frameworks and key libraries}}                                 |
| {{AREA, for example Frontend}} | {{frameworks and key libraries}}                                 |
| Tests                          | {{unit, integration and end-to-end test tools}}                  |
| Tooling                        | {{lint, formatting, CI, code-quality and secret-scanning tools}} |

Versions come from {{FILES THAT DEFINE VERSIONS, for example manifests and wrapper properties}}; read them rather than assuming. Do not add a dependency without approval; check whether the current stack already covers the need.

## Scope and setup

- {{PROJECTS: the independent projects or packages in this repository and where to run commands. State whether there is a root build.}}
- Use [docs/setup.md](docs/setup.md) for first-time setup and {{README LINKS: which README covers what}}. Do not treat documented but unrun builds or integrations as passing checks.
<!-- slot:package-registry -->
- Dependencies come from {{PUBLIC OR PRIVATE REGISTRIES}}. {{CREDENTIALS: environment variable names or config files that hold registry credentials, if any.}} Never write credentials into files, logs, commands shared in chat, or test fixtures.
<!-- /slot:package-registry -->

## Build and run commands

```sh
{{VERIFIED COMMANDS, grouped by project directory: install, build, run locally, all tests, one test, integration/e2e, lint, type check.}}
```

{{PREREQUISITES for commands that need a running app, credentials or services.}}

### Formatting

- {{FORMATTER: the formatter and its configuration files, or "No formatter runs in scripts or CI" and which config files describe the style.}}
- Format only the lines you change. Do not run a formatter or an IDE bulk reformat over files you did not otherwise touch.

### Known tooling gaps

- {{BROKEN OR MISLEADING SCRIPTS, missing configuration, and checks that only work after a full install. Write "None known" if the audit found none.}}

## Project structure

```
{{ANNOTATED TREE of the top two or three levels, with one short note per entry.}}
```

A file's location should make its owner obvious. Put feature code in its feature package or module, not in a shared utilities folder.

## Architecture

- {{OVERVIEW: the main components and how they communicate.}}

### {{AREA}} constraints

- {{LAYERING: the allowed dependency direction and what each layer may and may not do.}}
- {{BOUNDARIES: what must never cross a boundary, for example persistence entities or SDK objects in API responses.}}
- {{ERRORS: the error model, error codes and the central handler.}}
- {{SECURITY: authentication, authorization, the public endpoint list and who may change it.}}
- {{ENFORCEMENT: lint or build rules that enforce these boundaries. Never disable them to cross a boundary.}}

## Coding rules

### General

- Do not introduce dependencies without approval.
- Do not change public contracts ({{CONTRACTS: API paths, message shapes, error codes, event names}}) without approval.
- Do not invent business rules. If a requirement or an external system's behavior is ambiguous, stop and ask.
- Reuse existing utilities before adding new ones.
- Comments explain constraints and non-obvious intent, not what the next line does.

### Naming and configuration

- {{FILE AND TEST NAMING per area.}}
- {{CONFIGURATION: where settings are read from, environment variable prefixes, and which values are secrets.}}

### {{AREA}}

- {{AREA-SPECIFIC RULES: patterns to follow, validation, persistence and migrations, API documentation.}}

### Security and logging

<!-- slot:compliance -->

- Never log tokens, passwords, keys or personal data. {{LOG POLICY: where logs go and who reads them.}}
- {{SECURITY BASELINE: production defaults that must not be relaxed, such as disabled debug endpoints and restricted CORS.}}
<!-- /slot:compliance -->

## Testing requirements

- Add or update tests with the change itself, never in a later cleanup. A bug fix includes a regression test.
- {{TEST LEVELS: what unit, integration and end-to-end tests cover, and what to mock. Tests must never call real external services.}}
- No skipped or focused tests: {{FRAMEWORK MARKERS, for example @Disabled, xit, fit, .only}}, and no commented-out tests.
- Tests create and clean up their own data and must pass in any order.
- Do not change a test only to make it pass unless the test itself is wrong, and say so when that happens. Do not chase a coverage percentage.

## Verification

- {{PER AREA: the command for the nearest test, then the broader suites to run when shared behavior changes.}}
- Report which commands actually ran and any blocked gates; do not infer success from CI configuration.

## Git workflow

<!-- slot:vcs-flow -->

- Branch off `{{BASE BRANCH}}` and merge back into it. Use other branches only when the user names them.
- Branch names: `{{BRANCH PATTERN, for example <ISSUE-KEY>-<short-slug>}}`. Commit subjects: `{{COMMIT PATTERN}}`.
- Changes go through a {{pull request / merge request}}.
<!-- /slot:vcs-flow -->
- Do not push, force-push, merge, tag or rewrite shared history unless explicitly asked.
<!-- slot:secret-scanning -->
- {{SECRET SCANNER: the pre-commit secret scanner, or "No secret scanner is configured" as a known gap.}} Never bypass commit hooks (`--no-verify`).
<!-- /slot:secret-scanning -->

## Agent workflow rules

- Before changing an area, read its README section and the matching page in [Documentation references](#documentation-references).
- Stay within the requested scope. If something outside it seems necessary, stop and ask.
- Stop and ask when a requirement is ambiguous instead of quietly picking an interpretation.
- Ask before you implement. Before changing any file for a task, ask all your open questions in one batch and wait for the answers. If you have none, say so and list the assumptions you will rely on before you start.
- If a new question comes up while implementing, stop work on the affected step, ask it, and wait for the answer. Do not guess and continue. For a user story, record the question and answer in the plan's open questions, and update the plan if the answer changes it.
- Keep documentation in step with the code in the same change. When an external design page becomes outdated, tell the user; do not edit it unless asked.
- Report bugs, contradictions or stale documentation plainly instead of coding around them.
- Verify rather than assume. Run the nearest tests and lint before claiming a change works.

## Working on a user story

Work through these phases in order, and do not start a phase until the previous one's exit condition is met.

### 1. Intake

<!-- slot:work-items -->

- If you are given an issue key (`{{ISSUE KEY FORMAT}}`), read the issue from {{TRACKER}} with the available tool; otherwise ask the user to paste the story. Use the story as pasted in chat when no key is given.
- The tracker is read-only: never comment on, transition, assign or create issues unless the user asks.
<!-- /slot:work-items -->
- Restate the acceptance criteria as numbered items (`AC-1`, `AC-2`, ...). If the story has no testable criteria, draft them and ask the user to confirm them.
- Ask about every ambiguity now, including external-system behavior, error cases, UI text and affected deployments.
- Exit condition: the acceptance criteria are confirmed and there are no open questions that would change the design.

### 2. Discovery

- Read the relevant README sections, the matching documentation references, and the existing code and tests in each affected area.
- Identify the affected layers, any public contracts involved, and the existing tests to extend.
- Flag anything that needs explicit approval: new dependencies, contract or schema changes, security changes, or work outside the story.

### 3. Plan (approval gate)

Write the plan to `docs/plans/<ISSUE-KEY>-<short-slug>.md`, starting from a copy of [docs/plans/\_template.md](docs/plans/_template.md). For a story without an issue key, use a descriptive slug and ask for the key. The plan contains the summary and source, numbered acceptance criteria, open questions, affected files by layer, contract/schema/configuration changes, a test plan mapping each criterion to a test, ordered implementation steps as a checklist, and risks and out-of-scope items.

Stop and ask for approval. Do not create a branch or change code until the plan is approved. If the plan later changes materially, update the file and ask again.

### 4. Branch

- After approval, update the base branch from the remote. If the working tree has unrelated changes, ask before switching.
- Create the story branch and commit the plan file as the first commit.

### 5. Implement

- Follow the plan's steps in layer order: {{LAYER ORDER per area, for example migration, repository, service, controller}}.
- Write or extend the planned tests in the same step, then run the nearest tests.
- After each verified step, tick it in the plan and make a local commit. Never push.
- If a question comes up during a step, stop that step, ask, and wait for the answer before continuing it. Record the question and answer in the plan.
- Record deviations in the plan. If a step shows the plan is wrong or needs out-of-scope work, stop and ask.

### 6. Verify

- Run the commands under [Verification](#verification), nearest tests first, then the broader suites the change affects.
- Run end-to-end suites or full stacks only when the user provides the environment and credentials.
- Go through the [Definition of done](#definition-of-done).

### 7. Validate acceptance criteria

Add an evidence table to the plan and repeat it in chat:

| AC   | Evidence                             | Command            | Result |
| ---- | ------------------------------------ | ------------------ | ------ |
| AC-1 | `<TestClass>#<method>` or spec title | exact command used | Passed |

- Every acceptance criterion needs at least one passing automated test.
- If a criterion cannot be automated (for example, visual behavior or a real external system), mark its result "Needs manual check", explain why, and describe the check the user must perform. Never report it as met.
- A story is not done while any automatable criterion lacks passing evidence. Criteria marked "Needs manual check" do not block completion, but list each one and its check in the hand-off.

### 8. Hand-off

- Report what changed, the commits on the branch, the evidence table, the commands run and their results, blocked gates, stale documentation and follow-ups.
- Offer a tracker comment summarizing the work, and post it only after the user approves.
- Leave pushing and opening the {{pull request / merge request}} to the user unless explicitly asked.

## Guardrails

- Never hand-edit generated output: {{GENERATED PATHS}}. Treat {{MIGRATION HISTORY PATH}} as history; add a new migration for schema changes.
- Do not churn {{VENDORED CODE, WRAPPERS, LOCKFILES}} outside an intentional update. Preserve unrelated working-tree changes.
- Do not commit tokens, passwords, private data, database files or generated logs. {{KNOWN RISKY SCRIPTS, for example scripts that print secrets.}}

## Definition of done

A change is done when each item that applies has been verified, not assumed:

- [ ] For a user story, the plan in `docs/plans/` was approved and is current, every automatable acceptance criterion has passing evidence, and manual checks are listed.
- [ ] Code sits in the correct layer or package, and lint passes, including boundary rules.
- [ ] Tests exist for the new or changed behavior, the nearest tests were run, and the exact commands and results are reported.
- [ ] {{AREA-SPECIFIC CHECKS, for example: a new endpoint is authenticated, validated, documented and uses the central error handling.}}
- [ ] Schema changes come with a new migration.
- [ ] No secrets, tokens or private data appear in code, logs or fixtures.
- [ ] Affected READMEs, this file and API docs are updated, and stale external pages are reported.
- [ ] There is no unrelated churn in generated files, lockfiles, vendored code or other people's changes.

## Documentation references

<!-- slot:design-docs -->

Treat these documents as design intent; the code wins where they differ.

| Document           | Use for            | Known drift from code |
| ------------------ | ------------------ | --------------------- |
| {{TITLE AND LINK}} | {{WHAT IT IS FOR}} | {{DRIFT, or —}}       |

<!-- /slot:design-docs -->
