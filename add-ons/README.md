# Add-ons

Add-ons adapt the generic kit to a company or team without changing the core files. There are two kinds:

- **Profiles** replace the content of named slots in `AGENTS.md` and `docs/setup.md`.
- **Enforcement hooks** add deterministic checks that block risky agent actions. See [enforcement-hooks/](enforcement-hooks/).

## Slot markers

Each slot is a block between an opening and a closing HTML comment:

```markdown
<!-- slot:secret-scanning -->

- A gitleaks pre-commit hook scans every commit. Never bypass commit hooks (`--no-verify`).
<!-- /slot:secret-scanning -->
```

Rules:

- A slot name appears as a pair of markers; the same slot may appear in more than one file (for example `package-registry` in both `AGENTS.md` and `docs/setup.md`).
- Only the text between the markers changes when a profile is applied. Everything outside the markers belongs to the core.
- Keep the markers after bootstrapping so a later profile change is a small, reviewable edit.

## Slot catalogue

| Slot               | Where                                     | Purpose                                                                         | Generic default                                                                                                       |
| ------------------ | ----------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `work-items`       | AGENTS.md, user story Intake              | Where stories come from, issue-key format, what the agent may do in the tracker | Read the issue with the available tool or ask the user to paste it. The tracker is read-only unless the user asks.    |
| `design-docs`      | AGENTS.md, Documentation references       | Design documents with their use and known drift from code                       | A table of documents found in the repository (`docs/`, ADRs) with a drift column.                                     |
| `vcs-flow`         | AGENTS.md, Git workflow                   | Base branch, branch and commit naming, review flow, release triggers            | Branch off the default branch, descriptive branch names, conventional commit subjects, changes through pull requests. |
| `package-registry` | AGENTS.md, Scope and setup; docs/setup.md | Private registries, credentials, network access                                 | Public registries; no credentials needed.                                                                             |
| `secret-scanning`  | AGENTS.md, Git workflow; docs/setup.md    | Secret-scanning tool and how to enable it                                       | No scanner configured: record it as a gap and recommend adding one.                                                   |
| `onboarding`       | docs/setup.md, introduction               | Where accounts, access and licenses are requested                               | Ask the team lead for repository and tool access.                                                                     |
| `compliance`       | AGENTS.md, Security and logging           | Logging, privacy and security baselines required by policy                      | Never log secrets or personal data; keep production defaults locked down.                                             |

## Available profiles

| Profile                                                                        | Fits teams that use                                                                                                                   |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| Generic (the defaults above)                                                   | Any hosting, tracker and registry                                                                                                     |
| [company-atlassian-gitlab-artifactory/](company-atlassian-gitlab-artifactory/) | Jira and Confluence through the Atlassian MCP server, GitLab merge requests, JFrog Artifactory, gitleaks, customer-installed software |

## Applying or swapping a profile

1. Copy the profile folder next to the repository's agent files, or open it from this kit.
2. Ask the agent: "Apply the `<profile>` add-on: replace the content of each slot with the profile's text, adapted to this repository, and fill its placeholders from the audit. Change nothing outside the slot markers."
3. Review the diff; only lines between slot markers should change.
4. Run the **gap-review** prompt.

## Writing a new profile

Create a folder with a `README.md` (who the profile is for and what it assumes) and a `slots.md` with one section per slot, each containing the replacement text. Use `{{...}}` placeholders for values that differ per repository. Leave out slots the profile does not change; they keep their generic default.
