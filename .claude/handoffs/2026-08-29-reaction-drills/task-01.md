# Task 01 - Reaction models and engine: modes, formats, scoring

- **Run:** `.claude/handoffs/2026-08-29-reaction-drills/`
- **Depends on:** runs 2, 3 and 5 complete
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
`ReactionProvider` learns two new modes (defense, goNoGo) and a second format (endurance 60),
and `ReactionResult` carries what they need. Pure Dart, `FakeAsync`-testable, no UI.

## Context the worker needs
- `lib/providers/reaction_provider.dart`, `lib/models/reaction_mode.dart`,
  `lib/models/reaction_direction.dart`, `lib/models/reaction_result.dart`,
  `test/providers/reaction_provider_test.dart`, `test/models/reaction_result_test.dart` (run 2).
- `SettingsProvider.stance` is read by the page (task-02), not here: the engine takes the
  stance as an argument so it stays free of providers.
- Existing behaviour (countdown 3 s, wait 1.5 to 4 s, 2 s timeout, 700 ms feedback, false
  starts do not consume the trial) is unchanged for tap and direction.

## Files
- `lib/models/reaction_mode.dart` - modify - two new values.
- `lib/models/reaction_format.dart` - create - `ReactionFormat`.
- `lib/models/incoming_punch.dart` - create - `IncomingPunch`.
- `lib/models/defense_zone.dart` - create - `DefenseZone`.
- `lib/models/reaction_result.dart` - modify - new fields and derived numbers.
- `lib/providers/reaction_provider.dart` - modify.
- `docs/architecture.md` - modify - rows; extend the "Reaction trainer" paragraph.

## Spec

### Enums
- `ReactionMode { tap, direction, defense, goNoGo }`; labels "Tap", "Direction", "Defense",
  "Go / No-go"; descriptions for the new two: "A punch is called. Tap the defense that beats it."
  and "Mint means go, red means hold. Do not bite on the feint." `fromName` fallback tap.
- `ReactionFormat { standard, endurance }`; labels "10 trials", "Endurance 60"; `fromName`
  fallback standard.
- `IncomingPunch { jab, cross, leadHook, rearHook, body }`; `label` ("JAB", "CROSS", "LEAD HOOK",
  "REAR HOOK", "BODY").
- `DefenseZone { slipLeft, slipRight, roll, block }`; `label` ("SLIP LEFT", "SLIP RIGHT",
  "ROLL", "BLOCK").
- `DefenseZone defenseFor(IncomingPunch punch, Stance stance)` (top-level in
  `defense_zone.dart`): orthodox: jab -> slipRight, cross -> slipLeft, leadHook -> roll,
  rearHook -> roll, body -> block. Southpaw mirrors the slips (jab -> slipLeft, cross -> slipRight).
  One-line comment: slipping outside the lead hand, the conventional same-stance answer.

### `ReactionResult` changes
New fields with defaults so old JSON loads: `ReactionFormat format = standard`,
`int correctHolds = 0`, `int falseAlarms = 0`, `int durationSeconds = 0` (endurance: 60;
standard: seconds from first stimulus to the last response, rounded). JSON keys `format`,
`correct_holds`, `false_alarms`, `duration_seconds`. `trials` becomes
`reactionMillis.length + misses + correctHolds + falseAlarms`. New derived getters:
`int? get firstHalfAverage`, `int? get secondHalfAverage` (averages of the first and second
halves of `reactionMillis` in order; null if fewer than 4 hits), `int? get decayPercent`
(`(second - first) * 100 ~/ first`, null when either is null), `double? get accuracy`
(hits / (hits + misses + falseAlarms), null when the denominator is 0; correct holds are not
hits, they are neutral).

### `ReactionProvider` changes
```dart
void start(ReactionMode mode, {ReactionFormat format = ReactionFormat.standard, Stance stance = Stance.orthodox});
void tap({ReactionDirection? direction, DefenseZone? defense});   // replaces tap({zone})
ReactionFormat get format; Stance get stance;
IncomingPunch? get incomingPunch;   // defense mode, set on stimulus
bool get isGo;                      // goNoGo: true on go stimuli, false on hold stimuli (undefined otherwise: return true)
int get secondsLeft;                // endurance: whole seconds until the 60 s elapse; 0 in standard
int get correctHolds; int get falseAlarms;
static const int enduranceSeconds = 60;
```
Behaviour:
- Defense mode: on stimulus pick `incomingPunch` uniformly with `random`; a tap with
  `defense == defenseFor(incomingPunch, stance)` records the time; any other tap (including
  `defense == null`) is a miss with feedback "Wrong defense"; no tap in 2 s is "Too slow".
- Go / No-go: on stimulus pick `isGo` with 70% probability. Go: as tap mode. Hold: a tap during
  the stimulus is a false alarm (`falseAlarms++`, feedback "Hold!"), and the stimulus times out
  after 1000 ms as a correct hold (`correctHolds++`, feedback "Good hold", trial consumed).
  Feedback text for the arena to colour: "Good hold" counts as positive (task-02 colours by
  text just like ms).
- Endurance: `start(..., format: endurance)` records `formatStartedAt` at the first stimulus;
  after each consumed trial, if `clock().difference(formatStartedAt) >= 60 s` -> complete,
  else next trial (no trial cap; `trial` keeps counting). `secondsLeft` = 60 minus elapsed,
  clamped, computed on read. A one-shot 60 s timer is not needed; the check at trial end is
  enough, so a run ends within one trial of the minute.
- Standard: unchanged (10 consumed trials). `durationSeconds` set on complete for both.
- `result` gets `format`, `correctHolds`, `falseAlarms`, `durationSeconds`.
- `cancel()` resets the new fields too.

### docs/architecture.md
Rows for the three new model files; extend the Reaction trainer paragraph with the modes and
formats and the stance mapping.

## Out of scope
- UI, Progress, persistence changes beyond the JSON fields (the store already round-trips
  `ReactionResult.toJson`).
- Ears-only, two-player, rhythm, combination memory, custom presets.

## Acceptance criteria
- [ ] Old JSON without the new keys parses with defaults; new JSON round-trips.
- [ ] `defenseFor` mapping holds for both stances (10 cases).
- [ ] Defense mode with `Random(1)`: a matching zone records the time; a wrong zone is a miss
      with "Wrong defense".
- [ ] Go / No-go: a hold stimulus with no tap becomes a correct hold after 1000 ms; a tap on it
      is a false alarm; a go stimulus tap records time; `accuracy` and `trials` add up.
- [ ] Endurance with a fake clock advanced ~4 s per trial completes after the first trial that
      ends past 60 s, `result.format == endurance`, `durationSeconds == 60`, `decayPercent`
      is computed when 4+ hits exist.
- [ ] Tap and direction behave exactly as before (existing tests untouched and green).
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: extend `test/providers/reaction_provider_test.dart` and
  `test/models/reaction_result_test.dart`; create `test/models/defense_zone_test.dart`.
