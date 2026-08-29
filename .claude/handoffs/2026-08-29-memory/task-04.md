# Task 04 - Review round 3 fixes

- **Run:** `.claude/handoffs/2026-08-29-memory/`
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (developer: adjust the existing tests)

## Goal
Two corrections from the Architect's device review of run 3 (`docs/review-log.md` R3-02, R3-03).

## Context the worker needs
- `lib/providers/session_provider.dart` (`_buildRecord`, `_leaveWorkPhase`, `skipPhase`),
  `test/providers/session_provider_test.dart`.
- `lib/theme/app_theme.dart` (`inputDecorationTheme`), `lib/widgets/journal_field.dart`.
- Another workflow is editing other files in `lib/` right now; touch only the files below.

## Files
- `lib/providers/session_provider.dart` - modify - `completed` semantics.
- `lib/theme/app_theme.dart` - modify - hint colour only.
- `test/providers/session_provider_test.dart` - modify - one new case.

## Spec

### R3-02 `completed` means every round was completed
Skipping the last round's work phase reaches `_finish(completed: true)`, so a record can say
`completed: true` with `roundsCompleted: 0`. In `_buildRecord` (or at the `_finish` call
sites), set `completed` to `completed && _roundsCompleted >= workout.roundCount`. The
`sessionCompleted` vs `sessionEnded` event stays as it is (the session did run to its end);
only the record's flag changes. Test: a 2-round workout where round 1 finishes normally and
round 2 is skipped yields `record.completed == false`, `roundsCompleted == 1`; a fully run
workout still yields `true`.

### R3-03 Journal hints are fainter
In `AppTheme.dark.inputDecorationTheme`, hint style colour becomes `chalkFaint` (was
`chalkMuted`), so a hint cannot be mistaken for an entry. No other theme change.

## Out of scope
- Anything else in those files; no new files.

## Acceptance criteria
- [ ] The new test passes and the full suite stays green.
- [ ] `flutter analyze` 0 issues; `dart format` on touched files.

## Verification
`flutter test test/providers/session_provider_test.dart`, then `flutter test`, `flutter analyze`.
