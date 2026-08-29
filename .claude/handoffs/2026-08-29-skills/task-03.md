# Task 03 - Footwork drills

- **Run:** `.claude/handoffs/2026-08-29-skills/`
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
A bundled catalogue of footwork drills, each a `Workout` of type footwork with movement cues,
listed from the Skills hub and run on the existing session engine and detail page.

## Context the worker needs
- `lib/data/workout_library.dart` for the authoring style (all `const`), and the cue notation
  rules in `.claude/handoffs/2026-08-29-core-loop/task-02.md`.
- `lib/widgets/workout_tile.dart`, `lib/pages/workout_detail_page.dart` are reused as is.
- Movement vocabulary for cues (words only, stance-neutral): `step in`, `step out`, `step back`,
  `step left`, `step right`, `pivot`, `pivot left`, `pivot right`, `circle left`,
  `circle right`, `switch`, `reset`, `bounce`, `hold`, `L-step`, `exit`. Punches may appear in
  the advanced drills only.

## Files
- `lib/data/footwork_drills.dart` - create - `footworkDrills`, `findFootworkDrill`.
- `lib/pages/footwork_page.dart` - create.
- `lib/pages/skills_page.dart` - modify - wire the Footwork card.
- `docs/architecture.md` - modify - rows.

## Spec

### `footworkDrills`
`const List<Workout> footworkDrills`, ids prefixed `fw_`, `type: TrainingType.footwork`,
`isCustom: false`, each round 4 to 8 cues (first at 3 to 5 s, none in the last 5 s, strictly
increasing). Author these five:

| id | name | difficulty | rounds | theme |
|---|---|---|---|---|
| `fw_step_reset` | Step and Reset | beginner | 3 x 1:30 / 0:30 | step in / step out / step back, always `reset` to stance |
| `fw_pivot_circuit` | Pivot Circuit | beginner | 3 x 1:30 / 0:30 | pivot left / right, circle, `hold` |
| `fw_angles` | Angles Off the Jab | intermediate | 4 x 2:00 / 0:45 | `1, pivot`, `1, step left`, `1-2, L-step` |
| `fw_box_step` | Box Step Shuffle | intermediate | 4 x 2:00 / 0:45 | four-corner stepping, `bounce`, `switch` |
| `fw_cut_the_ring` | Cut the Ring | advanced | 5 x 2:00 / 0:45 | pressure footwork: `step in`, `circle left`, `1-2, step in`, `exit` |

`Workout? findFootworkDrill(String id)`. Drill ids never collide with `workoutLibrary` ids and
drills are not part of `workoutLibrary` (the Train tab does not list them).

### `FootworkPage`
`Scaffold`, transparent `AppBar` (back), `ListView` padded `spaceLg`:
`SectionHeader(title: 'Footwork', eyebrow: 'MOVEMENT DRILLS')`, then a `WorkoutTile` per
drill separated by `spaceSm`; tap pushes `WorkoutDetailPage(workout: drill)`.

### Skills hub
Set the Footwork card's `onTap` to push `FootworkPage`. No card is SOON any more.

## Out of scope
- New widgets or session changes.
- Any edit to `workout_library.dart`.

## Acceptance criteria
- [ ] `footworkDrills.length == 5`, every invariant from the library tests holds (unique
      `fw_` ids, rounds non-empty, cues strictly increasing within `0 < at < work - 4`, texts
      under 30 chars, `isCustom` false, type footwork), and no id exists in `workoutLibrary`.
- [ ] Footwork page lists five tiles; tapping one opens the detail page with "Start workout".
- [ ] Skills hub has no SOON card.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/data/footwork_drills_test.dart`, `test/pages/footwork_page_test.dart`.
