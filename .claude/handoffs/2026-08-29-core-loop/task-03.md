# Task 03 - Session engine

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
`SessionProvider`: a pure-Dart state machine that runs a `Workout` through prepare, work and
rest phases on one `Timer.periodic`, emits the events the cue services and the screen react to
(round start, 10 s warning, final 30 s, cues, rest, complete), supports pause / resume / skip /
end, and produces a `SessionRecord` when it finishes. No widgets, no platform calls, fully
testable with `FakeAsync`.

## Context the worker needs
- `docs/decisions.md` "Session engine counts down from a wall-clock deadline": derive
  `secondsLeft` from an injectable clock, do not decrement a counter.
- `docs/architecture.md` Layers: providers hold state only, never import widgets or services.
- Models from task-02: `Workout`, `RoundSpec`, `RoundCue`, `SessionRecord`, `Stance`, `Difficulty`.

## Files
- `lib/models/session_phase.dart` - create - `SessionPhase` enum.
- `lib/models/session_event.dart` - create - `SessionEventType` enum and `SessionEvent`.
- `lib/providers/session_provider.dart` - create - `SessionProvider`.
- `lib/utils/duration_format.dart` - create - `formatClock`, `formatMinutes`.
- `lib/main.dart` - modify - add `ChangeNotifierProvider.value(value: session)` where
  `final session = SessionProvider();` is created in `main()` next to `settings` and passed
  into `BoxerOsApp` (add a `session` constructor parameter).
- `docs/architecture.md` - modify - module map rows; a "Session engine" paragraph under Layers.

## Spec

### `SessionPhase`
`{ idle, prepare, work, rest, complete }`.

### `SessionEvent`
```dart
enum SessionEventType {
  prepareStarted, roundStarted, tenSecondWarning, finalThirty, cue,
  restStarted, roundSkipped, paused, resumed, sessionCompleted, sessionEnded,
}
class SessionEvent {
  const SessionEvent(this.type, {required this.round, this.cueText});
  final SessionEventType type; final int round; final String? cueText;
}
```
`cueText` is non-null only for `cue`. `==` / `hashCode` / `toString` on all three fields.

### `SessionProvider`
```dart
class SessionProvider extends ChangeNotifier {
  SessionProvider({DateTime Function()? clock});   // defaults to DateTime.now
  Workout? get workout;
  SessionPhase get phase;          // idle at construction
  int get round;                   // 1-based; 0 while idle; stays on the last round in complete
  int get secondsLeft;             // in the current phase, 0 while idle/complete
  int get phaseSeconds;            // total seconds of the current phase, for progress bars
  bool get isPaused;
  bool get isActive;               // phase is prepare, work or rest
  String? get currentCue;          // latest cue text this round, null until the first cue
  int get elapsedSeconds;          // whole session, pauses excluded
  int get roundsCompleted;
  Stance get stance; Difficulty get difficulty;
  SessionRecord? get record;       // set on complete / end, null otherwise
  Stream<SessionEvent> get events; // broadcast
  void start(Workout workout, {required Stance stance, required Difficulty difficulty});
  void pause(); void resume(); void togglePause();
  void skipPhase();
  void end();
  void reset();
  @override void dispose();
}
```

Behaviour:
- `start` while active: call `end()` first (no throw). It sets `round = 1`, phase `prepare`
  with `workout.prepareSeconds` (if `prepareSeconds == 0`, go straight to work), records
  `startedAt = clock()`, emits `prepareStarted` (or `roundStarted`), starts
  `Timer.periodic(const Duration(seconds: 1), _tick)`, notifies.
- Timing: on entering a phase store `phaseStartedAt = clock()` and `phaseSeconds`. Each tick,
  when not paused, `secondsLeft = phaseSeconds - clock().difference(phaseStartedAt).inSeconds`,
  clamped at 0. `elapsedSeconds` accumulates `clock()` deltas between ticks while not paused.
  On `pause()` store the remaining seconds and emit `paused`; on `resume()` set
  `phaseStartedAt = clock()` and `phaseSeconds = remaining` so the deadline is rebuilt, emit
  `resumed`. Pausing while idle or complete is a no-op.
- Work-phase marks, checked every tick in this order, each fired at most once per round via
  flags reset at round start: `finalThirty` when `secondsLeft <= 30` and `workSeconds > 45`;
  `tenSecondWarning` when `secondsLeft <= 10` and `workSeconds > 20`; cues: while the next
  unfired cue has `atSecond <= elapsedInRound`, set `currentCue`, emit `cue`, advance the index
  (so a stalled tick fires every cue it passed, in order).
- Transitions when `secondsLeft` reaches 0: prepare -> work round 1 (`roundStarted`);
  work -> `roundsCompleted++`, then if it was the last round -> `complete` (`sessionCompleted`),
  else if `restSeconds > 0` -> rest (`restStarted`, `currentCue = null`) else -> next round work
  (`roundStarted`); rest -> next round work. A transition that lands on 0-second phases keeps
  chaining in the same tick.
- `skipPhase`: same transition as reaching 0, but emit `roundSkipped` first; a skipped work
  round does not count as completed.
- `end()`: only while active; cancels the timer, phase `complete`, builds the record with
  `completed = false`, emits `sessionEnded`, notifies. `sessionCompleted` builds the record
  with `completed = true`. Record fields come straight from the state; `id` is
  `startedAt.millisecondsSinceEpoch.toString()`, `type` / `difficulty` from the workout,
  `stance` from the `start` argument.
- `reset()`: cancels the timer, returns everything to idle (record cleared), no event.
- Timer cancelled and events controller closed in `dispose()`. `notifyListeners()` on every
  state change, once per tick at most.

### `duration_format.dart`
`String formatClock(int seconds)` -> `'3:00'`, `'0:09'`, `'12:05'` (negative treated as 0).
`String formatMinutes(int seconds)` -> `'20 min'`, `'1 min'` for anything under 90 s, rounds
to nearest minute otherwise.

### docs/architecture.md
Module map rows for the four files; a "Session engine" paragraph: one timer, wall-clock deadline,
events stream, who listens (task-04 `CueController`, task-05 `SessionPage`).

## Out of scope
- No audio, haptics, TTS or wake lock (task-04).
- No UI (task-05).
- No history persistence (run 3).

## Acceptance criteria
- [ ] `start` on a 2 x 5 s / 3 s workout with 2 s prepare, driven by a fake clock and
      `FakeAsync`, emits in order: prepareStarted, roundStarted(1), restStarted(1),
      roundStarted(2), sessionCompleted(2); `roundsCompleted == 2`, `record.completed`.
- [ ] A 60 s work round emits `finalThirty` exactly once at 30 s left and `tenSecondWarning`
      exactly once at 10 s left; a 15 s round emits neither.
- [ ] Cues at 3 s and 20 s in a 60 s round emit `cue` with their text at those elapsed seconds,
      and `currentCue` shows the latest; `currentCue` is null during rest.
- [ ] If the clock jumps 25 s between two ticks, both cues in that window fire, in order, once.
- [ ] `pause` freezes `secondsLeft` for any elapsed wall time; `resume` continues from it.
- [ ] `skipPhase` in work moves to rest without incrementing `roundsCompleted`; `end` mid-round
      yields `record.completed == false` with the rounds completed so far.
- [ ] `formatClock(185) == '3:05'`, `formatMinutes(1210) == '20 min'`.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/providers/session_provider_test.dart` using `fakeAsync` from
  `package:fake_async` (available through `flutter_test`; if the import is not resolvable, add
  `fake_async` to `dev_dependencies` with the version already in `pubspec.lock`) and a mutable
  `DateTime now` injected as `clock: () => now`, with a helper that advances both together
  one second at a time. `test/utils/duration_format_test.dart`.
