# Project Guidelines

Read this file before changing code. Code and configuration in this repository are the source of truth for current behavior; the documents under [Documentation references](#documentation-references) explain design intent. Where they disagree, follow the code and report the mismatch rather than silently resolving it.

## Project context

- BerthPlan is a web portal where harbour planners book vessel calls into berth windows and resolve scheduling conflicts. The backend owns scheduling rules; the frontend is a single-page app used on office desktops.
- It runs as a hosted service for one port operator, with a staging and a production environment. Planners rely on it during night shifts, so failed deployments and slow queries matter as much as features.
- Prefer a small, verified change over a broad, partly verified one.

## Domain terms

| Term                    | Meaning in this repository                                                                          |
| ----------------------- | --------------------------------------------------------------------------------------------------- |
| Berth                   | A mooring position with length and depth limits (`berth` package, `berths` feature)                 |
| Vessel call             | One planned visit of a vessel, with ETA, ETD and required berth length (`vesselcall` package)       |
| Berth window            | The time a vessel call occupies a berth; windows on one berth must not overlap (`schedule` package) |
| Conflict                | Two berth windows that overlap on the same berth, or a vessel longer than the berth                 |
| Planner, harbour master | Roles from the identity provider; only harbour masters may override a conflict                      |

If you meet an unfamiliar term, ask instead of guessing its meaning.

## Tech stack

| Area     | Current choice                                                                                                       |
| -------- | -------------------------------------------------------------------------------------------------------------------- |
| Runtimes | JDK 21 with the Gradle wrapper; Node.js 22 with npm                                                                  |
| Backend  | Spring Boot 3.3 (Web MVC), Spring Data JPA, PostgreSQL 16, Flyway, MapStruct, Spring Security OAuth2 resource server |
| Frontend | Angular 19, TypeScript (strict), NgRx 19, Angular Material                                                           |
| Tests    | JUnit 5, Testcontainers (PostgreSQL), MockMvc; Jasmine/Karma; Playwright for end-to-end                              |
| Tooling  | Checkstyle, ESLint with `eslint-plugin-boundaries`, Prettier, GitHub Actions, gitleaks pre-commit hook               |

Versions come from `backend/build.gradle.kts`, `backend/gradle/wrapper/gradle-wrapper.properties` and `frontend/package.json`; read them rather than assuming. Do not add a dependency without approval.

## Scope and setup

- `backend/` (Gradle) and `frontend/` (npm) are independent projects; run commands from the project directory. There is no root build. `e2e/` holds the Playwright suite.
- Use [docs/setup.md](docs/setup.md) for first-time setup, `backend/README.md` for database and profiles, and `frontend/README.md` for the dev server and proxy. Do not treat documented but unrun builds as passing checks.
<!-- slot:package-registry -->
- Dependencies come from Maven Central and the public npm registry; no credentials are needed. Never write credentials into files, logs, commands shared in chat, or test fixtures.
<!-- /slot:package-registry -->

## Build and run commands

```sh
# repository root: local database
docker compose -f compose.dev.yml up -d postgres

# backend/
./gradlew bootRun --args='--spring.profiles.active=local'
./gradlew build
./gradlew test
./gradlew test --tests 'com.berthplan.schedule.service.BerthWindowServiceTest'
./gradlew checkstyleMain

# frontend/
npm ci
npm start                          # http://localhost:4200, proxies /api to :8080
npm run lint
npm test -- --watch=false --browsers=ChromeHeadless
npx ng test --include=src/app/features/schedule/**/*.spec.ts --watch=false --browsers=ChromeHeadless

# e2e/ (needs backend and frontend running)
npx playwright test tests/booking.spec.ts
```

Backend integration tests start PostgreSQL through Testcontainers and need a running Docker engine.

### Formatting

- Backend style is enforced by Checkstyle (`backend/config/checkstyle.xml`); frontend style by Prettier (`frontend/.prettierrc`) through `npm run lint`.
- Format only the lines you change. Do not run a formatter over files you did not otherwise touch.

### Known tooling gaps

- `npm run e2e` in `frontend/package.json` points to a removed Protractor setup; use the Playwright command above.

## Project structure

```
berthplan/
├── AGENTS.md, CLAUDE.md, README.md
├── compose.dev.yml               local PostgreSQL
├── docs/setup.md, docs/plans/    setup guide; one plan per story
├── docs/adr/                     architecture decision records
├── backend/src/main/java/com/berthplan/
│   ├── <feature>/                berth, vesselcall, schedule: controller/, service/, repository/, entity/, dto/, mapper/
│   ├── common/                   ApiError, ErrorCode, GlobalErrorHandler
│   └── security/                 SecurityConfig, role mapping
├── backend/src/main/resources/db/migration/   Flyway migrations
├── frontend/src/app/
│   ├── core/                     auth, HTTP interceptors, error handling
│   ├── shared/                   stateless UI components and pipes
│   └── features/<feature>/       data-access/ (API, store), ui/, feature/
└── e2e/                          Playwright tests
```

## Architecture

- The backend exposes a REST API under `/api/v1`; the frontend calls it through feature API services. Scheduling rules live only in the backend.

### Backend constraints

- Layering is one-directional: controller → service → repository. Controllers handle routing, DTO binding, `@Valid` and OpenAPI annotations only. Services own business rules and are the only callers of repositories.
- JPA entities never cross the HTTP boundary; controllers return DTOs produced by MapStruct mappers.
- Errors: throw a subclass of `BerthPlanException` with an `ErrorCode` (`BP-<AREA>-###`); `GlobalErrorHandler` turns it into `ApiError` (`code`, `title`, `status`, `detail`, `path`, `traceId`). Never return stack traces.
- Security: every endpoint requires a bearer token except `/actuator/health`. Only the `HARBOUR_MASTER` role may override a conflict. Do not widen the public list without approval.

### Frontend constraints

- `core/` must not import `features/`; `shared/` must not import `core/` or `features/`; features must not import each other. `eslint-plugin-boundaries` enforces this; never disable the rule.
- HTTP calls live only in `features/<feature>/data-access/`. Components in `ui/` use inputs and outputs only.

## Coding rules

### General

- Do not introduce dependencies without approval.
- Do not change public contracts (REST paths, DTO shapes, error codes) without approval.
- Do not invent scheduling rules. If port operations behavior is ambiguous, stop and ask.
- Comments explain constraints and non-obvious intent, not what the next line does.

### Naming and configuration

- Backend tests are `*Test.java` (unit) and `*IT.java` (Testcontainers) in the package mirroring the class under test. Frontend specs are `*.spec.ts` beside the file; Playwright tests are `e2e/tests/*.spec.ts`.
- Settings come from `application*.yml`; environment variables use the `BERTHPLAN_` prefix. `BERTHPLAN_DB_PASSWORD` is a secret.

### Backend

- Constructor injection, MapStruct mappers, and `@ConfigurationProperties` records with validation for new settings.
- Schema changes need a new Flyway migration `V<n>__<description>.sql`.

### Frontend

- Strict TypeScript: no `any`, no non-null assertions to hide a real null. Handle loading, error and empty states explicitly.
- User-visible text goes through the i18n files in `src/assets/i18n/`.

### Security and logging

<!-- slot:compliance -->

- Never log tokens, passwords or personal data about crew. Logs go to the hosting provider's log service, readable by the operations team.
- Actuator exposes only health; Swagger UI is disabled in production; allowed origins come from configuration.
<!-- /slot:compliance -->

## Testing requirements

- Add or update tests with the change itself. A bug fix includes a regression test.
- Unit tests mock repositories. Repository and API flows use `*IT.java` with Testcontainers; tests never call real external services.
- No skipped or focused tests: no `@Disabled`, `xit`, `fit`, `.only` or commented-out tests.
- Tests create and clean up their own data and must pass in any order.
- Do not change a test only to make it pass unless the test itself is wrong, and say so.

## Verification

- Backend: run the nearest test class with `./gradlew test --tests '<class>'`, then `./gradlew build` when shared behavior changes.
- Frontend: run the nearest spec, then `npm run lint` and the full `npm test` run.
- Report which commands actually ran and any blocked gates.

## Git workflow

<!-- slot:vcs-flow -->

- Branch off `main` and merge back into it through a pull request.
- Branch names: `BP-<number>-<short-slug>`. Commit subjects: `BP-<number>: Imperative summary`.
<!-- /slot:vcs-flow -->
- Do not push, force-push, merge, tag or rewrite shared history unless explicitly asked.
<!-- slot:secret-scanning -->
- A gitleaks pre-commit hook scans every commit. Never bypass it (`--no-verify`).
<!-- /slot:secret-scanning -->

## Agent workflow rules

- Before changing an area, read its README and the matching document in [Documentation references](#documentation-references).
- Stay within the requested scope; stop and ask when something outside it seems necessary or a requirement is ambiguous.
- Ask before you implement: ask all open questions in one batch and wait for the answers, or say you have none and list your assumptions. If a new question comes up while implementing, stop the affected step, ask, and wait; record the answer in the plan.
- Keep documentation in step with the code in the same change. Report bugs, contradictions or stale documentation plainly.
- Verify rather than assume.

## Working on a user story

Work through these phases in order, and do not start a phase until the previous one's exit condition is met.

1. **Intake.**
   <!-- slot:work-items -->
   Read the issue (`BP-<number>`) with the issue-tracker tool, or ask the user to paste it. The tracker is read-only unless the user asks.
   <!-- /slot:work-items -->
   Restate the acceptance criteria as `AC-1`, `AC-2`, ... and ask every open question. Exit: criteria confirmed, no open design questions.
2. **Discovery.** Read the affected code, tests and ADRs; flag contract, schema or security changes for approval.
3. **Plan (approval gate).** Write `docs/plans/BP-<number>-<slug>.md` from [docs/plans/\_template.md](docs/plans/_template.md) with a test plan mapping every criterion to a test. Stop until the user approves.
4. **Branch.** Update `main`, create the story branch, commit the plan first.
5. **Implement.** Backend: migration, repository, service, controller. Frontend: data-access, ui, feature. Write tests with each step, run the nearest tests, tick the step, commit locally. Never push. If a question comes up, stop that step and ask before continuing it.
6. **Verify.** Run the Verification commands and walk through the Definition of done.
7. **Validate acceptance criteria.** Fill the evidence table (AC, evidence, exact command, result). A criterion that cannot be automated is "Needs manual check" with the check described; it never counts as met but does not block completion.
8. **Hand-off.** Report changes, commits, the evidence table, commands and results, blocked gates, stale docs and follow-ups. Offer a tracker comment; post it only after approval.

## Guardrails

- Never hand-edit `build/`, `dist/`, `node_modules/`, coverage or Playwright reports. Existing Flyway migrations are history; add a new one.
- Do not churn the Gradle wrapper or `package-lock.json` outside an intentional update. Preserve unrelated working-tree changes.
- Do not commit secrets, database dumps or logs.

## Definition of done

- [ ] For a story, the plan was approved and is current, every automatable criterion has passing evidence, and manual checks are listed.
- [ ] Code sits in the correct layer; Checkstyle and `npm run lint` pass.
- [ ] Tests exist for the change, the nearest tests were run, and commands and results are reported.
- [ ] A new endpoint is authenticated, validated, documented in OpenAPI, and uses `ErrorCode` with `GlobalErrorHandler`.
- [ ] Schema changes come with a new Flyway migration.
- [ ] No secrets or personal data in code, logs or fixtures.
- [ ] READMEs, this file and OpenAPI docs are updated.

## Documentation references

<!-- slot:design-docs -->

| Document                                                           | Use for                                                  | Known drift from code                                         |
| ------------------------------------------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------- |
| [ADR 001 - Berth window model](docs/adr/001-berth-window-model.md) | Why windows are half-open intervals `[start, end)`       | —                                                             |
| [ADR 002 - Conflict overrides](docs/adr/002-conflict-overrides.md) | Who may override conflicts and how overrides are audited | Says planners may override; code allows only `HARBOUR_MASTER` |

<!-- /slot:design-docs -->
