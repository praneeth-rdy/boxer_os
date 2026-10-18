# Run: test coverage for the untested substantive files

/ 2026-10-18 /

## Why

91 test files mirror `lib/`, but 35 of 126 `lib/` files have no mirrored test. The owner chose
to cover the substantive ones only: the files with real logic, not the presentational widgets or
single-enum models where a test would restate the code.

CI (`.github/workflows/ci.yml`) already runs `dart format --set-exit-if-changed`, `flutter
analyze`, `flutter test` and a debug APK build on every pull request, so anything landing here is
enforced from the next PR onwards.

## Tasks

| Task | Worker | Covers |
|---|---|---|
| task-01 | assistant | `services/notification_service.dart`, `services/wake_lock_service.dart`, `theme/app_motion.dart` |
| task-02 | assistant | the models and data constants with parsing or fallback logic |
| task-03 | assistant | `widgets/reaction_arena.dart` |

No dependencies between them: the three touch disjoint files under `test/`.

## Out of scope for the whole run

- Any change under `lib/` or `android/`. If a test cannot be written without one, the task
  returns `BLOCKED` with the reason; it does not edit production code.
- The presentational widgets and enum-only models deliberately left uncovered
  (`section_header`, `stat_tile`, `empty_state`, `session_phase`, `quote`, `boxing_fact` and
  the rest). `docs/backlog.md` records the decision.
- New dependencies. `flutter_test` is already there.

## Standing rule for every task in this run

Do not write a test that only re-asserts a constructor assigning its fields. Cover logic:
parsing, fallbacks, derived values, error containment, rendering that depends on state. If a
file in your list turns out to have no logic worth a test, skip it and say so in NOTES rather
than padding the suite.
