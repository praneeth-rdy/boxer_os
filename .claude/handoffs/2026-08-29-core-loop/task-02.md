# Task 02 - Models and the bundled workout library

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The immutable value types the whole app is built on (`TrainingType`, `RoundCue`, `RoundSpec`,
`Workout`, `SessionRecord`) with JSON round-tripping, plus the twelve-workout starter library
that makes the app useful on day one.

## Context the worker needs
- `.claude/CLAUDE.md` "Code guidelines" > Structure: models are immutable, `final` fields,
  `const` constructors, `copyWith` where mutation is needed.
- `docs/product.md` "Modules" (training engine) and "Answered questions" (1, 3, 7).
- `lib/models/stance.dart` and `lib/models/difficulty.dart` exist from task-01; reuse them.
- Cue text is spoken aloud by TTS in task-04 and shown in huge type on screen. Keep every cue
  short (under 30 characters), stance-neutral (say "lead hook", never "left hook") and in the
  notation below.

## Files
- `lib/models/training_type.dart` - create - `TrainingType` enum.
- `lib/models/round_cue.dart` - create - `RoundCue`.
- `lib/models/round_spec.dart` - create - `RoundSpec`.
- `lib/models/workout.dart` - create - `Workout`.
- `lib/models/session_record.dart` - create - `SessionRecord`.
- `lib/data/workout_library.dart` - create - `workoutLibrary` and lookup helpers.
- `docs/architecture.md` - modify - module map rows for the files above.

## Spec

### `TrainingType`
`{ shadowBoxing, heavyBag, speedBag, mittWork, sparring, footwork, conditioning, strength, custom }`
with `String get label` ("Shadow boxing", "Heavy bag", "Speed bag", "Mitt work", "Sparring",
"Footwork", "Conditioning", "Strength", "Custom") and `static TrainingType fromName(String?)`
falling back to `custom`.

### `RoundCue`
`const RoundCue({required int atSecond, required String text})`. `atSecond` is seconds elapsed
since the round's work phase started. `toJson` / `fromJson` (`{'at': int, 'text': String}`).
Equality: implement `==` and `hashCode` on the two fields (needed for tests and `copyWith` comparisons).

### `RoundSpec`
`const RoundSpec({required int workSeconds, required int restSeconds, this.focus = '', this.cues = const []})`.
`focus` is a 2 to 4 word round title shown while no cue is active ("Jab only", "Doubles and
triples"). `toJson` / `fromJson` (`work`, `rest`, `focus`, `cues`). `==` / `hashCode`.

### `Workout`
```dart
const Workout({
  required this.id,             // stable snake_case string, e.g. 'shadow_foundations'
  required this.name,
  required this.type,
  required this.difficulty,
  required this.rounds,         // List<RoundSpec>, never empty
  this.description = '',        // one or two sentences
  this.prepareSeconds = 10,
  this.isCustom = false,        // true for timer-built sessions, never for library entries
});
```
Getters: `int get roundCount`, `int get totalSeconds` (prepare + sum of work + rest, no rest after
the last round), `int get estimatedMinutes` (`(totalSeconds / 60).ceil()`), `bool get hasCues`.
`toJson` / `fromJson` with enums stored by `name`; `fromJson` uses the `fromName` fallbacks and
defaults missing fields. `copyWith` for `name`, `rounds`, `difficulty`.

Factory `Workout.quick({required int rounds, required int workSeconds, required int restSeconds})`:
`id: 'quick'`, `name: 'Round timer'`, `type: TrainingType.custom`, `difficulty:
Difficulty.beginner`, `isCustom: true`, `prepareSeconds: 10`, `rounds` = `rounds` identical
`RoundSpec(workSeconds, restSeconds)` with empty focus and no cues. Clamp `rounds` to 1..30,
`workSeconds` to 10..600, `restSeconds` to 0..300.

### `SessionRecord`
```dart
const SessionRecord({
  required this.id,               // String, millisecondsSinceEpoch of startedAt as a string
  required this.workoutId,
  required this.workoutName,
  required this.type,             // TrainingType
  required this.difficulty,
  required this.stance,
  required this.startedAt,        // DateTime
  required this.durationSeconds,  // actual elapsed, pauses excluded
  required this.roundsCompleted,  // rounds whose work phase finished
  required this.roundsPlanned,
  required this.completed,        // false when ended early
  this.rating,                    // int? 1..5, set by the journal in run 3
  this.notes,                     // String?
});
```
`int get workMinutes` (`(durationSeconds / 60).round()`), `toJson` / `fromJson` (ISO-8601 for
`startedAt`, enums by name, nullable fields omitted when null), `copyWith` for `rating`, `notes`.

### Cue notation (use in every workout)
Punches: `1` jab, `2` cross, `3` lead hook, `4` rear hook, `5` lead uppercut, `6` rear uppercut,
suffix `b` for body (`1b`, `2b`, `3b`). Chain with hyphens: `1-2`, `1-1-2`, `1-2-3-2`.
Defence and movement, as words: `slip`, `slip left`, `slip right`, `roll`, `pull`, `parry`,
`block`, `pivot`, `step back`, `step in`, `circle left`, `circle right`, `reset`, `exit`.
Mixed cue: `1-2, slip, pivot, exit`. Pace words: `light`, `sharp`, `power`, `speed`, `breathe`.
Spoken form is derived by task-04 (digits become words, `b` becomes "body"), so keep the raw
text exactly in this notation.

### `workoutLibrary` (`lib/data/workout_library.dart`)
`const List<Workout> workoutLibrary` (everything `const`), plus
`Workout? findWorkout(String id)` and `List<Workout> workoutsOfType(TrainingType type)`.
Author these twelve. Round focus and cues are yours to write within the notation; each cued
round gets 4 to 8 cues spread through the round (first at second 3 to 5, then roughly every
20 to 30 s, none in the last 5 s). Rounds are `m:ss` work / rest.

| id | name | type | difficulty | rounds | description theme |
|---|---|---|---|---|---|
| `shadow_foundations` | Shadow Foundations | shadowBoxing | beginner | 3 x 2:00 / 1:00 | jab, 1-2, basic slips; round focus "Jab only", "1-2", "Add the slip" |
| `shadow_flow` | Shadow Flow | shadowBoxing | intermediate | 5 x 3:00 / 1:00 | combos with movement between them |
| `championship_rounds` | Championship Rounds | shadowBoxing | advanced | 12 x 3:00 / 1:00 | fight simulation, sparse cues (3 to 4 per round): pace, pressure, exits |
| `bag_basics` | Bag Basics | heavyBag | beginner | 4 x 2:00 / 1:00 | single punches then 1-2, stepping off after each |
| `power_rounds` | Power Rounds | heavyBag | advanced | 6 x 3:00 / 1:00 | body-head combos, power on the last punch |
| `speed_bag_rhythm` | Speed Bag Rhythm | speedBag | intermediate | 4 x 2:00 / 0:45 | alternate hands, doubles, `speed`, `reset` |
| `mitt_partner` | Mitt Work Partner | mittWork | intermediate | 5 x 3:00 / 1:00 | called combos for a holder to feed |
| `sparring_six` | Sparring Six | sparring | advanced | 6 x 3:00 / 1:00 | reminders only, 3 cues per round: `breathe`, `circle left`, `exit` |
| `footwork_ladder` | Footwork Ladder | footwork | beginner | 4 x 2:00 / 0:45 | step in / step out, pivots, circling; no punches until round 4 |
| `fight_conditioning` | Fight Conditioning | conditioning | intermediate | 6 x 1:00 / 0:30 | one exercise per round as the focus: "Burpees", "Squat jumps", "Mountain climbers", "Shadow sprint", "Push-ups", "Plank"; one cue at second 5 naming it and one at 45 saying `sharp` |
| `fighter_strength` | Fighter Strength | strength | intermediate | 5 x 2:00 / 1:00 | circuit round titles: "Push-ups", "Rows or pull-ups", "Split squats", "Med-ball slams", "Core"; two cues each |
| `footwork_combo_20` | Footwork + Combination | footwork | intermediate | 6 x 2:30 / 0:45 | the concept's example session, about 20 min: alternating footwork rounds and combo rounds ending with `1-2, slip, pivot, exit` |

Library invariants (tests check these): ids unique and snake_case; every workout has at least
one round; `workSeconds >= 30` except conditioning (`>= 60` there too, fine); `restSeconds >= 0`;
cues sorted by `atSecond`, strictly increasing, `0 < atSecond < workSeconds - 4`; no cue text
longer than 30 characters; `isCustom` false; `estimatedMinutes` of `footwork_combo_20` is 20
plus or minus 1.

### docs/architecture.md
Add module map rows for the six files. Add a short "Bundled data" line under the Layers section
saying the library is `const` Dart, not JSON.

## Out of scope
- No `Combination`, `Drill`, vocabulary or generator (run 2).
- No `JournalEntry`; the record carries `rating` and `notes` instead.
- No persistence code (`HistoryStore` is run 3).
- No UI.

## Acceptance criteria
- [ ] `Workout.fromJson(w.toJson())` equals `w` field by field for every library workout
      (compare via `toJson` maps).
- [ ] `SessionRecord.fromJson(r.toJson())` round-trips, including null `rating` and `notes`.
- [ ] `Workout.quick(rounds: 0, workSeconds: 5, restSeconds: 900)` clamps to 1 / 10 / 300.
- [ ] `totalSeconds` for 3 x 120 / 60 with 10 s prepare is `10 + 3 * 120 + 2 * 60 = 490`.
- [ ] `workoutLibrary.length == 12` and every invariant listed above holds.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/models/workout_test.dart`, `test/models/session_record_test.dart`,
  `test/models/round_spec_test.dart`, `test/data/workout_library_test.dart` (the invariants as
  one test each).
