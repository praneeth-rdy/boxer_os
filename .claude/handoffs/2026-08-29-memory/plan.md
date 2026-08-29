# Run 3: Memory (2026-08-29)

## Goal

Give the app a memory: sessions and reaction results persist on the device, every finished
session ends in a journal sheet (rating, what worked, what needs work, sparring notes), the
Progress tab shows the week, the streak, the split by type, reaction trends and milestone
badges, the Home tab recommends today's session from history and shows the weekly snapshot,
and a Settings page exposes stance, difficulty, cue toggles and About.

Builds on runs 1 and 2. Decision D-01: history is a JSON list in `shared_preferences` behind
`HistoryStore`, swappable later.

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | History store, provider, stats and the journal sheet | developer | assistant |
| 02 | `task-02.md` | Progress tab, journal list, milestones | developer | assistant |
| 03 | `task-03.md` | Home and Settings | developer | assistant |

Sequential (02 and 03 read `HistoryProvider` and `TrainingStats` from 01).

## Done means

- `flutter analyze` 0 issues, `flutter test` green, debug APK builds.
- Finish a session -> journal sheet -> saved; Progress shows it; Home's streak and week update;
  Settings changes stance and toggles and they persist across a restart.
- `docs/architecture.md` persistence section lists the new keys and the history schema.
