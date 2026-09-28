# \<ISSUE-KEY>: \<Story title>

- **Source:** \<tracker link or "chat">
- **Base branch:** `<base branch>`
- **Story branch:** `<ISSUE-KEY>-<short-slug>`
- **Status:** Draft | Approved | In progress | Done

## Summary

\<One or two paragraphs: what the user needs and why.>

## Acceptance criteria

- **AC-1:** \<testable statement>
- **AC-2:** \<testable statement>

## Open questions and assumptions

- [ ] \<question for the user, or assumption to confirm>

## Affected areas

| Layer                               | Files or packages |
| ----------------------------------- | ----------------- |
| \<area and layer>                   |                   |
| Tests                               |                   |
| Docs (READMEs, AGENTS.md, API docs) |                   |

## Contract, schema and configuration changes

- API paths, message shapes, error codes, events: \<none, or details; requires approval>
- Schema migration: \<none, or file name>
- Configuration: \<none, or details>
- UI text keys and element IDs: \<none, or details>

## Test plan

| AC   | Level (unit, integration, e2e) | Planned test |
| ---- | ------------------------------ | ------------ |
| AC-1 |                                |              |

## Implementation steps

- [ ] 1. \<small step that can be verified on its own>
- [ ] 2. \<next step>

## Risks and out of scope

- **Risks:** \<what could go wrong, affected deployments>
- **Out of scope:** \<what this story will not do>

## Deviations

- \<date>: \<what changed from the approved plan and why>

## Acceptance-criteria evidence

| AC   | Evidence                             | Command            | Result                               |
| ---- | ------------------------------------ | ------------------ | ------------------------------------ |
| AC-1 | `<TestClass>#<method>` or spec title | exact command used | Passed / Failed / Needs manual check |

## Manual checks

- \<AC, why it cannot be automated, and the exact check the user must perform>
