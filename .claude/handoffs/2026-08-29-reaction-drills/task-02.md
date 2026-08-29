# Task 02 - Reaction screens and Progress trend

- **Run:** `.claude/handoffs/2026-08-29-reaction-drills/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The reaction page offers four modes and the Standard / Endurance format; the arena renders the
defense grid and the go / hold flash; results show accuracy and the endurance decay; Progress
shows bests per mode and the latest endurance decay.

## Context the worker needs
- `lib/pages/reaction_page.dart`, `lib/widgets/reaction_arena.dart` (run 2, motion touches
  from run 5), `lib/pages/progress_page.dart` (reaction section), `StatTile`, `BarChart`,
  `SkillCard`, `SegmentedButton` theme, `SettingsProvider.stance`, `AppMotion` (run 5).
- Task-01 API: `start(mode, format:, stance:)`, `tap(direction:, defense:)`, `incomingPunch`,
  `isGo`, `secondsLeft`, result getters.

## Files
- `lib/pages/reaction_page.dart` - modify.
- `lib/widgets/reaction_arena.dart` - modify.
- `lib/widgets/defense_grid.dart` - create - `DefenseGrid`.
- `lib/pages/progress_page.dart` - modify - reaction section.
- `lib/utils/milestones.dart` - modify - one new badge.
- `lib/models/milestone.dart` - no change.
- `docs/architecture.md` - modify - rows.

## Spec

### Mode picker (`ReactionPage`, idle state)
Under the header: a `SegmentedButton<ReactionFormat>` (labels "10 trials" / "Endurance 60"),
page state, default standard. Then four `SkillCard`s: Tap (`Icons.touch_app_rounded`),
Direction (`Icons.open_with_rounded`), Defense (`Icons.shield_rounded`), Go / No-go
(`Icons.traffic_rounded`), each calling `reaction.start(mode, format: format, stance:
settings.stance)`. Below the cards, a `caption`: "Defense uses your {stance label} stance:
slip outside the jab." (from settings).

### Running header
Standard: "TRIAL {n} OF 10". Endurance: "{secondsLeft}s LEFT" in `label` plus the trial count
after a middle dot. Right side: `mode.label` uppercase.

### `ReactionArena` changes
- Defense mode: during `stimulus`, the centre shows `incomingPunch.label` in `displayHero`
  (`FittedBox`), and the whole arena is a `DefenseGrid` (below) whose zones call
  `onTap(defense: zone)`; during `waiting` the grid is visible with labels dimmed so the boxer
  knows the layout; a wrong tap flashes `warning` like a miss.
- Go / No-go: `stimulus` background is `rest` with "GO" when `isGo`, `accent` with "HOLD" when
  not. Feedback "Good hold" colours `rest`; "Hold!" colours `warning`.
- Tap and direction unchanged.
- `onTap` signature becomes `void Function({ReactionDirection? direction, DefenseZone? defense})`.

### `DefenseGrid`
`const DefenseGrid({required void Function(DefenseZone) onZone, required bool isArmed, Widget? centre})`.
A 2 x 2 grid of opaque `GestureDetector`s (`onTapDown`) with `line` hairline borders:
top-left SLIP LEFT, top-right SLIP RIGHT, bottom-left ROLL, bottom-right BLOCK, labels in
`label` at each zone's outer corner (`chalkMuted` when `isArmed`, `chalkFaint` otherwise);
`centre` (the punch word) is stacked over the grid, ignoring pointer events.

### Result view
Stat cells: BEST, AVERAGE, and a third: ACCURACY ("{n}%" from `accuracy`, "--" when null) for
defense / goNoGo, else the existing false-start line stays. Endurance results add a row:
"First half {a} ms · second half {b} ms" and a `displaySmall` line "{decayPercent}% slower
by the end" (or "faster" when negative, `rest` colour; "No decay data" when null). The Again
button repeats mode and format.

### Progress reaction section
Replace the single chart with: a row of up to four `StatTile`s, one per mode that has results,
value = best ms across the last 10 results of that mode, label = mode label uppercase (skip
modes with no results; if none, the existing "Run the reaction trainer" line). Below it the
existing `BarChart` of the last 10 bests (any mode). If the newest endurance result exists:
`caption` "Endurance: {decayPercent}% slower over 60 s" (or faster).

### Milestone
Add `endurance_first` "Went the minute" (`Icons.timer_rounded`): achieved when any result has
`format == endurance`. Keep it last in the list (eight badges now; update the milestone tests).

## Out of scope
- New modes beyond the three; sounds for stimuli; sharing results.

## Acceptance criteria
- [ ] Picker shows the format toggle and four cards; Defense start passes the settings stance.
- [ ] Defense stimulus shows the punch word over the grid; tapping the matching zone records
      a hit (fake clock); a wrong zone shows "Wrong defense".
- [ ] Go / No-go arena is mint "GO" or red "HOLD"; result shows ACCURACY.
- [ ] Endurance header counts down; result shows the decay line.
- [ ] Progress shows per-mode best tiles and the endurance caption when data exists; the
      milestone list has eight entries with "Went the minute" last.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/widgets/defense_grid_test.dart`, extend
  `test/pages/reaction_page_test.dart`, `test/pages/progress_page_test.dart`,
  `test/utils/milestones_test.dart`.
