# Task 02 - Reaction trainer

- **Run:** `.claude/handoffs/2026-08-29-skills/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
A reaction trainer with two modes: **Tap** (tap anywhere the instant the screen flashes) and
**Direction** (tap the edge the arrow points to). Ten trials, random delays, false-start
detection, and a result with best and average reaction time that run 3 will store in history.

## Context the worker needs
- `.claude/CLAUDE.md` "Architecture": the provider holds state and timers, the page renders.
  Same testability rules as `SessionProvider`: injectable clock and `Random`.
- `lib/providers/session_provider.dart` for the style of a timer-driven provider.
- `lib/theme/app_theme.dart`, `lib/widgets/pill_button.dart`, `lib/widgets/section_header.dart`,
  `lib/widgets/skill_card.dart`.

## Files
- `lib/models/reaction_mode.dart` - create - `ReactionMode`.
- `lib/models/reaction_direction.dart` - create - `ReactionDirection`.
- `lib/models/reaction_result.dart` - create - `ReactionResult`.
- `lib/providers/reaction_provider.dart` - create - `ReactionProvider`.
- `lib/pages/reaction_page.dart` - create - mode picker, the test, the result.
- `lib/widgets/reaction_arena.dart` - create - `ReactionArena`.
- `lib/pages/skills_page.dart` - modify - wire the Reaction card.
- `lib/main.dart` - modify - add `ChangeNotifierProvider(create: (_) => ReactionProvider())`.
- `docs/architecture.md` - modify - rows and a "Reaction trainer" paragraph.

## Spec

### Enums
`ReactionMode { tap, direction }` with `label` ("Tap", "Direction") and `description`
("Tap anywhere the moment the screen flashes.", "Tap the edge the arrow points to.").
`ReactionDirection { up, down, left, right }` with `IconData get icon`
(`Icons.arrow_upward_rounded` etc.).

### `ReactionResult`
```dart
const ReactionResult({
  required this.mode, required this.completedAt, required this.reactionMillis, // List<int>, hits only
  required this.falseStarts, required this.misses,
});
```
`int get trials => reactionMillis.length + misses`, `int? get bestMillis` (null when empty),
`int? get averageMillis` (rounded mean, null when empty). `toJson` / `fromJson` (ISO date, mode
by name). `copyWith` not needed.

### `ReactionProvider`
```dart
enum ReactionPhase { idle, countdown, waiting, stimulus, feedback, complete }
class ReactionProvider extends ChangeNotifier {
  ReactionProvider({DateTime Function()? clock, Random? random});
  static const int trialCount = 10;
  ReactionMode get mode; ReactionPhase get phase;
  int get trial;                        // 1-based, 0 while idle
  int get countdownSeconds;             // 3, 2, 1 during countdown
  ReactionDirection? get direction;     // set in stimulus for direction mode
  int? get lastMillis;                  // last hit, for the feedback flash
  String? get feedback;                 // 'Early!', 'Wrong side', or the ms text
  int get falseStarts; int get misses;
  ReactionResult? get result;           // set on complete
  void start(ReactionMode mode);
  void tap({ReactionDirection? zone});  // zone is non-null only from direction-mode zones
  void cancel();                        // back to idle, no result
  @override void dispose();
}
```
Flow: `start` -> `countdown` 3 s (one `Timer.periodic(1 s)` decrementing `countdownSeconds`,
cancelled at 0) -> trial 1 `waiting` for `1500 + random.nextInt(2500)` ms (a one-shot `Timer`)
-> `stimulus` (record `shownAt = clock()`, pick `direction` with `random` in direction mode)
-> on `tap`: `feedback` for 700 ms (one-shot `Timer`) -> next trial or `complete` after
`trialCount` trials. Tap semantics:
- during `waiting`: false start; `falseStarts++`, `feedback = 'Early!'`, go to `feedback`, then
  restart the same trial's wait (the trial is not consumed).
- during `stimulus`, tap mode or matching zone: `millis = clock().difference(shownAt).inMilliseconds`,
  append, `lastMillis`, `feedback = '$millis ms'`.
- during `stimulus`, direction mode with a wrong zone (or `zone == null`): `misses++`,
  `feedback = 'Wrong side'`, trial consumed.
- during `countdown`, `feedback`, `complete`, `idle`: ignored.
- If no tap arrives within 2000 ms of the stimulus: a miss with `feedback = 'Too slow'`
  (one-shot `Timer`, cancelled on tap).
`complete` builds `ReactionResult(completedAt: clock())`. `cancel()` and `dispose()` cancel every
timer. All timers cancelled before a new one is scheduled; `notifyListeners` on each change.

### `ReactionArena` (`lib/widgets/reaction_arena.dart`)
`const ReactionArena({required ReactionProvider reaction, required void Function(ReactionDirection?) onTap})`.
Fills its parent. Background: `accent` during `stimulus` in tap mode, `surface` otherwise;
`rest` for 700 ms after a hit and `warning` after a false start or miss (drive from `phase ==
feedback` and `feedback` text: ms -> rest, otherwise warning). Centre content by phase:
countdown -> `countdownSeconds` in `displayHero`; waiting -> "WAIT" in `displaySmall`
`chalkMuted`; stimulus in tap mode -> "GO" in `displayHero` `onAccent`; stimulus in direction
mode -> `direction.icon` at 200 px in `chalk`; feedback -> `feedback` text in `displayLarge`.
Hit zones: tap mode wraps everything in one `GestureDetector` (`onTapDown` -> `onTap(null)`).
Direction mode: a `Column` of top zone (`Expanded`, flex 1), middle `Row` of left and right
zones (flex 2), bottom zone (flex 1), each an opaque `GestureDetector` calling `onTap(zone)`
on `onTapDown`; zones get a `line` hairline border so the boxer can see them. Use `onTapDown`,
not `onTap`, so timing excludes the tap-up.

### `ReactionPage` (`StatefulWidget`, `Consumer<ReactionProvider>`)
- `phase == idle`: `SectionHeader(title: 'Reaction', eyebrow: 'REACTION TRAINER')` and two
  `SkillCard`s (one per mode, icon `Icons.touch_app_rounded` / `Icons.open_with_rounded`)
  that call `reaction.start(mode)`. Transparent `AppBar` with back.
- running (`countdown`..`feedback`): no app bar; top row eyebrow "TRIAL {trial} OF 10" and
  `mode.label.toUpperCase()`; the `ReactionArena` in an `Expanded`; bottom `PillButton('Stop',
  ghost, sessionTapTarget)` calling `cancel()`. `PopScope(canPop: false)` while running, system
  back calls `cancel()` (no dialog; nothing is lost).
- `complete`: eyebrow "RESULT", `mode.label` in `displayLarge`, two stat cells (`bestMillis`
  and `averageMillis` as "{n} ms" in `displayMedium`, labels BEST and AVERAGE, `--` when null),
  a `bodyMuted` line "{falseStarts} false starts, {misses} misses", then
  `PillButton('Again', filled, 56)` -> `start(result.mode)` and `PillButton('Done', outlined, 56)`
  -> `cancel()` + `Navigator.pop`.
- Dispose: if the page is popped while running, call `cancel()` (in `dispose`, via the
  provider captured in `initState` or `context.read` before dispose).

### `main.dart`
Add `ChangeNotifierProvider(create: (_) => ReactionProvider())` to the providers list.

### Skills hub
Set the Reaction card's `onTap` to push `ReactionPage`.

## Out of scope
- Persisting results (run 3 stores `ReactionResult` in history).
- Sounds or haptics for stimuli (services live outside the tree; revisit in run 4).
- Punch/defense word stimuli and combination memory (later).

## Acceptance criteria
- [ ] With a fake clock and `Random(1)` under `FakeAsync`: `start(tap)` counts 3, 2, 1 then
      waits between 1.5 s and 4 s, shows the stimulus, a tap 230 ms later records 230,
      feedback lasts 700 ms, and after ten hits `result.bestMillis` and `averageMillis` are right.
- [ ] A tap during `waiting` increments `falseStarts`, shows 'Early!' and does not consume the trial.
- [ ] In direction mode a wrong zone is a miss and a matching zone records the time; no tap
      within 2 s is a miss with 'Too slow'.
- [ ] `cancel()` mid-trial returns to idle with no result and no timers pending
      (`FakeAsync.pendingTimers` empty after `cancel`).
- [ ] Widget test: mode picker -> arena with countdown -> stimulus -> result screen.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/providers/reaction_provider_test.dart`,
  `test/models/reaction_result_test.dart`, `test/pages/reaction_page_test.dart`.
