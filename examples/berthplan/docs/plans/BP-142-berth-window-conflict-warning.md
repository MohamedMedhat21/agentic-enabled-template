# BP-142: Warn when a vessel call overlaps an existing berth window

- **Source:** issue BP-142 (fictional)
- **Base branch:** `main`
- **Story branch:** `BP-142-berth-window-conflict-warning`
- **Status:** Done

## Summary

Planners can book a vessel call into a berth window that overlaps another window on the same berth, and only notice the clash later. The booking dialog should warn about the overlap before saving, and the API should refuse overlapping bookings unless a harbour master overrides.

## Acceptance criteria

- **AC-1:** Creating a berth window that overlaps an existing window on the same berth returns 409 with error code `BP-SCHED-004` and the conflicting window's ID.
- **AC-2:** Windows that only touch (one ends exactly when the next starts) do not conflict.
- **AC-3:** A user with the `HARBOUR_MASTER` role can create an overlapping window by sending `override=true`; the override is recorded with user and time.
- **AC-4:** The booking dialog shows a warning with the conflicting vessel's name before the planner saves.
- **AC-5:** The warning is readable in the dark theme.

## Open questions and assumptions

- [x] Does "touching" count as a conflict? Answer: no; windows are half-open `[start, end)` as in ADR 001.
- [x] May planners override? Answer: no, only harbour masters (ADR 002 is outdated; reported to its owner).

## Affected areas

| Layer              | Files or packages                                                                                                    |
| ------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Backend migration  | `db/migration/V18__berth_window_override.sql`                                                                        |
| Backend service    | `schedule/service/BerthWindowService`, `schedule/repository/BerthWindowRepository`                                   |
| Backend controller | `schedule/controller/BerthWindowController`, `common/ErrorCode`                                                      |
| Frontend           | `features/schedule/data-access/`, `features/schedule/ui/booking-dialog/`                                             |
| Tests              | `BerthWindowServiceTest`, `BerthWindowControllerIT`, `booking-dialog.component.spec.ts`, `e2e/tests/booking.spec.ts` |

## Contract, schema and configuration changes

- New error code `BP-SCHED-004` (approved).
- New optional request field `override` on `POST /api/v1/berth-windows` (approved).
- Migration `V18__berth_window_override.sql` adds `override_by` and `override_at`.
- New i18n key `schedule.booking.conflictWarning`.

## Test plan

| AC   | Level                 | Planned test                                                                             |
| ---- | --------------------- | ---------------------------------------------------------------------------------------- |
| AC-1 | Backend integration   | `BerthWindowControllerIT#rejectsOverlappingWindow`                                       |
| AC-2 | Backend unit          | `BerthWindowServiceTest#touchingWindowsDoNotConflict`                                    |
| AC-3 | Backend integration   | `BerthWindowControllerIT#harbourMasterCanOverride`, `#plannerCannotOverride`             |
| AC-4 | Frontend spec and e2e | `BookingDialogComponent shows conflict warning`, `booking.spec.ts > warns about overlap` |
| AC-5 | Manual                | Visual check in the dark theme                                                           |

## Implementation steps

- [x] 1. Migration and repository query for overlapping windows.
- [x] 2. Service rule with half-open interval check and override handling.
- [x] 3. Controller, error code, OpenAPI annotations.
- [x] 4. Frontend API service and store effect for the conflict check.
- [x] 5. Booking dialog warning and i18n key.
- [x] 6. Playwright scenario.

## Risks and out of scope

- **Risks:** the overlap query must use the existing index on `(berth_id, start_at)`; checked with `EXPLAIN` in the integration test database.
- **Out of scope:** vessel-length conflicts (BP-150).

## Deviations

- Step 4: the conflict check uses the existing `GET /api/v1/berth-windows?berthId=` endpoint instead of a new one, so no additional contract change was needed.

## Acceptance-criteria evidence

| AC   | Evidence                                                                                 | Command                                                                                                                                             | Result             |
| ---- | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| AC-1 | `BerthWindowControllerIT#rejectsOverlappingWindow`                                       | `./gradlew test --tests 'com.berthplan.schedule.controller.BerthWindowControllerIT'`                                                                | Passed             |
| AC-2 | `BerthWindowServiceTest#touchingWindowsDoNotConflict`                                    | `./gradlew test --tests 'com.berthplan.schedule.service.BerthWindowServiceTest'`                                                                    | Passed             |
| AC-3 | `BerthWindowControllerIT#harbourMasterCanOverride`, `#plannerCannotOverride`             | `./gradlew test --tests 'com.berthplan.schedule.controller.BerthWindowControllerIT'`                                                                | Passed             |
| AC-4 | `BookingDialogComponent shows conflict warning`; `booking.spec.ts > warns about overlap` | `npx ng test --include=src/app/features/schedule/**/*.spec.ts --watch=false --browsers=ChromeHeadless`; `npx playwright test tests/booking.spec.ts` | Passed             |
| AC-5 | Not automated: contrast in the dark theme is a visual judgement                          | —                                                                                                                                                   | Needs manual check |

## Manual checks

- AC-5: switch the app to the dark theme, open the booking dialog for berth B3 on a date with an existing window, and confirm the warning text and icon are readable against the dialog background.
