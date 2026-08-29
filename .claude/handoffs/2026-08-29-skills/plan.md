# Run 2: Skills (2026-08-29)

## Goal

Fill the Skills tab: a stance-neutral, seeded combination generator with a practice mode that
runs on the session engine (spoken combos), a reaction trainer with tap and direction modes and
reaction-time scoring, and a bundled footwork drill catalogue. After this run every tab except
Progress does real work.

Builds on run 1 (`.claude/handoffs/2026-08-29-core-loop`): `Workout`, `RoundSpec`, `RoundCue`,
`SessionProvider`, `startSession`, `cueToSpeech`, `WorkoutTile`, `WorkoutDetailPage`,
`PillButton`, `StepperRow`, `SectionHeader`, `AppTheme`.

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Skills hub and the combination generator | developer | assistant |
| 02 | `task-02.md` | Reaction trainer | developer | assistant |
| 03 | `task-03.md` | Footwork drills | developer | assistant |

Sequential (all three touch `lib/pages/skills_page.dart`).

## Done means

- `flutter analyze` 0 issues, `flutter test` green, debug APK builds.
- Skills tab shows three cards; Combos generates repeatable combinations per difficulty and can
  start a practice session where they are spoken; Reaction runs ten trials in either mode and
  shows best and average; Footwork lists drills that run on the session engine.
- `docs/architecture.md` updated by each package.
