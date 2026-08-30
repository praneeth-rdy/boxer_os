# Task 02 - History icon, combination copy, footwork drills expansion

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Three small owner requests: the History card's book icon is ugly; two combination entries
carry inaccurate copy; the footwork catalogue doubles from five to ten drills.

## Files
- `lib/pages/progress_page.dart` - modify - History card icon.
- `lib/data/combination_library.dart` - modify - c37 description, c41 and c57 names.
- `lib/data/footwork_drills.dart` - modify - five more drills.
- `docs/architecture.md` - modify - the drills row count.

## Spec

### History icon
`Icons.menu_book_rounded` becomes `Icons.history_rounded` on the Progress History card.
Nothing else on the card changes.

### Combination copy
- c37 (`1-2, circle left`): description becomes "Land the two, then step off the line before
  they can answer." (The old line said "away from their power hand", which only holds against
  a southpaw.)
- c41 (`1-2-3-2-3`): name "Five-punch flurry" (two of the five are hooks, so "Five straight"
  was wrong).
- c57 (`1-2-5-2-3`): name "Uppercut five".
Update any test that asserts the old names.

### Footwork drills (append five, ids `fw_` prefixed, same invariants as the existing five)
| id | name | difficulty | rounds | theme and cue vocabulary |
|---|---|---|---|---|
| `fw_in_and_out` | In and Out | beginner | 3 x 1:30 / 0:30 | `step in`, `step out`, `1, step out`, `reset`, `bounce`; teaches entering and leaving range |
| `fw_lateral_lines` | Lateral Lines | beginner | 3 x 1:30 / 0:30 | `step left`, `step right`, `circle left`, `circle right`, `hold`; side-to-side with the head off centre |
| `fw_switch_and_go` | Switch and Go | intermediate | 4 x 2:00 / 0:45 | `switch`, `step in`, `1-2`, `switch`, `exit`; stance switches under control |
| `fw_pendulum` | Pendulum Step | intermediate | 4 x 2:00 / 0:45 | `bounce`, `step back`, `step in, 1`, `pendulum`, `reset`; rhythm and range with the pendulum step (add `pendulum` to the movement vocabulary) |
| `fw_ring_general` | Ring General | advanced | 5 x 2:00 / 0:45 | `cut left`, `cut right`, `step in, 1-2`, `pivot`, `hold`, `exit`; cutting the ring on a moving target (add `cut left`, `cut right` to the vocabulary) |
Each round: focus title, 4 to 8 cues, first at 3 to 5 s, none in the last 5 s, strictly increasing,
texts under 30 characters. Add `pendulum`, `cut left`, `cut right` to `movementTokens` in
`lib/data/boxing_vocabulary.dart` (that file is therefore also in scope).

## Acceptance criteria
- [ ] Progress History card uses `Icons.history_rounded`.
- [ ] c37 description, c41 and c57 names as above; library still 60 entries and all valid.
- [ ] `footworkDrills.length == 10`; all invariants in `test/data/footwork_drills_test.dart`
      hold for the new five (extend the test to cover the new ids).
- [ ] `flutter analyze` 0 issues; suite green.
