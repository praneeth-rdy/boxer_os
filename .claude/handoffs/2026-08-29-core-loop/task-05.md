# Task 05 - Session screen and Train tab

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** task-04
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The screens of the core loop: a Train tab with a quick round timer and the twelve-workout
library, a workout detail page, and the phone-down session screen with an arm's-length
countdown, the current cue in huge type, and glove-sized controls. Home gets a real start CTA.
This is the screen the product is judged on; it has to look premium and be legible across a gym.

## Context the worker needs
- `.claude/CLAUDE.md` "Conventions": session screen controls at 64 dp minimum (`AppTheme.
  sessionTapTarget` is 72), every state change also arrives by sound or haptics (task-04 does
  that; the screen only renders), `AppTheme` tokens only, extract widgets over `_buildX`.
- `docs/product.md` "Look and feel" and "Core loop". Think editorial, not dashboard: generous
  whitespace, the display face doing the talking, one accent.
- Providers: `SessionProvider` (task-03) and `SettingsProvider` (task-01) are in the tree.
  `workoutLibrary`, `workoutsOfType`, `Workout.quick` from task-02. `formatClock`,
  `formatMinutes` from task-03.
- Device: 393 x 873 dp portrait. `displayHero` at 168 px fits "12:00" across the width with
  `spaceLg` padding; use `FittedBox` so "0:09" and "12:00" never overflow.

## Files
- `lib/widgets/pill_button.dart` - create - `PillButton`.
- `lib/widgets/stepper_row.dart` - create - `StepperRow`.
- `lib/widgets/quick_timer_card.dart` - create - `QuickTimerCard`.
- `lib/widgets/workout_tile.dart` - create - `WorkoutTile`.
- `lib/widgets/round_clock.dart` - create - `RoundClock`.
- `lib/widgets/cue_banner.dart` - create - `CueBanner`.
- `lib/pages/train_page.dart` - rewrite.
- `lib/pages/workout_detail_page.dart` - create.
- `lib/pages/session_page.dart` - create.
- `lib/pages/session_complete_page.dart` - create.
- `lib/pages/home_page.dart` - modify - add the start CTA.
- `lib/utils/session_launcher.dart` - create - `startSession`.
- `docs/architecture.md` - modify - module map rows, a "Navigation" paragraph.

## Spec

### Starting a session (`lib/utils/session_launcher.dart`)
```dart
Future<void> startSession(BuildContext context, Workout workout)
```
Reads `SettingsProvider` and `SessionProvider` via `context.read`, calls
`session.start(workout, stance: settings.stance, difficulty: workout.difficulty)`, then
`Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const SessionPage()))`.
(Living in `utils/` because it is a function, not a widget; it may import providers, which is
allowed for the page layer it serves.)

### `PillButton`
`const PillButton({required String label, required VoidCallback? onPressed, PillStyle style = PillStyle.filled, double height = AppTheme.minTapTarget, IconData? icon})`
with `enum PillStyle { filled, outlined, ghost }`: filled = accent background / `onAccent`
text; outlined = `line` border, `chalk` text; ghost = no border, `chalkMuted` text. Full
width, `radiusPill`, label in `bodyStrong` (uppercase, letterSpacing 1 when height >= 64).
Use `Material` + `InkWell` so the ripple is clipped to the pill.

### `StepperRow`
`const StepperRow({required String label, required String value, required VoidCallback? onDecrement, required VoidCallback? onIncrement})`.
A row: label in `label` uppercase on the left, then `value` in `displayMedium`, then two
48 dp round icon buttons (`Icons.remove_rounded`, `Icons.add_rounded`) on `surfaceRaised`.
Long-press repeats are not needed.

### `QuickTimerCard` (`StatefulWidget`)
Card (`surface`, `radiusLg`, padding `spaceLg`) titled with eyebrow "ROUND TIMER" and title
"Quick start" in `displayMedium`. Three `StepperRow`s: Rounds (default 3, step 1, 1..30),
Work (default 3:00, step 15 s, 0:30..10:00, shown with `formatClock`), Rest (default 1:00,
step 15 s, 0:00..5:00). Below, a summary line in `bodyMuted`: "3 rounds, about 12 min"
(from `Workout.quick(...).estimatedMinutes`). Then a `PillButton` "Start" (filled, height
`minTapTarget + spaceSm`) calling `startSession(context, Workout.quick(...))`. State is local
to the card (values persist only while the tab lives in the `IndexedStack`).

### `WorkoutTile`
`const WorkoutTile({required Workout workout, required VoidCallback onTap})`. `surface` card,
`radiusMd`, padding `spaceMd`, min height 72. Left: name in `title`, second line in `caption`:
"{roundCount} x {formatClock(first round work)} · {difficulty.label}" (a middle dot is fine).
Right: `estimatedMinutes` in `displaySmall` with "MIN" in `label` under it. Whole tile tappable.

### `TrainPage` (rewrite)
`Scaffold` > `SafeArea` > `ListView` (horizontal padding `spaceLg`): `SectionHeader(title:
'Train', eyebrow: 'WORKOUTS AND TIMER')`, `QuickTimerCard`, `spaceXl`, then for each
`TrainingType` except `custom` that has workouts: a `label`-style uppercase group header
(`type.label`) and its `WorkoutTile`s separated by `spaceSm`. Tap pushes `WorkoutDetailPage`.

### `WorkoutDetailPage`
`const WorkoutDetailPage({required Workout workout})`. `Scaffold` with a transparent `AppBar`
(back arrow only). Body `ListView`: eyebrow `type.label` uppercase + difficulty, name in
`displayLarge`, description in `bodyMuted`, a stats row of three cells (`displayMedium` number
over `label`: rounds, work per round as `formatClock`, total as `estimatedMinutes` + "MIN"),
then a "Rounds" label and one row per round: "R{n}" in `bodyStrong`, focus (or "Free round") in
`body`, `formatClock(work)` + rest in `caption`, plus the cue count ("5 cues") in `caption`
when `cues` is non-empty. Bottom, pinned with `SafeArea` and padding: a `PillButton` "Start
workout" (filled, height 56) calling `startSession`. No stance or difficulty pickers here.

### `RoundClock`
`const RoundClock({required int secondsLeft, required int phaseSeconds, required SessionPhase phase})`.
Column: `formatClock(secondsLeft)` in `displayHero` inside a `FittedBox`, colour by phase
(`prepare` -> `warning`, `work` -> `accent`, `rest` -> `rest`, otherwise `chalk`), then a
6 dp-high progress bar (`ClipRRect` + `LinearProgressIndicator` or a `FractionallySizedBox`)
in the same colour over `line`, value `1 - secondsLeft / phaseSeconds` (guard divide by zero).

### `CueBanner`
`const CueBanner({required String? cue, required String fallback})`. Shows `cue ?? fallback`
centred in `displayMedium` (cue) or `bodyMuted` (fallback), max 2 lines, `AnimatedSwitcher`
250 ms fade between cue values. `fallback` is the round focus, or "Free round".

### `SessionPage`
`StatelessWidget` wrapped in `Consumer<SessionProvider>` (whole page; it is small).
Layout, `Scaffold` background `ink`, `SafeArea`, padding `spaceLg`:
1. Top row: eyebrow in `label`: "GET READY" during prepare, "ROUND {round} OF {roundCount}"
   during work and rest, "COMPLETE" when complete; trailing text in `label`: workout name.
2. Phase word in `displaySmall` coloured like the clock: "PREPARE" / "WORK" / "REST".
3. `Expanded` centre: `RoundClock`, `spaceLg`, `CueBanner`. The whole centre area is a
   `GestureDetector` that toggles pause on tap (glove-friendly). When paused, overlay the word
   "PAUSED" in `displayMedium` `chalkMuted` above the clock and dim the clock to 0.5 alpha.
4. Bottom: two rows of controls, each `sessionTapTarget` tall with `spaceSm` between:
   row 1: `PillButton` "Pause" / "Resume" (filled while running, outlined while paused);
   row 2: `Row` of `PillButton` "Skip" (ghost) and "End" (outlined) with `spaceSm` between.
Behaviour: `PopScope(canPop: false)` while `isActive`; a system back press shows a
`showDialog` "End session?" with "Keep going" / "End" (End calls `session.end()`). When
`phase == complete` the page replaces itself with `SessionCompletePage` (use
`WidgetsBinding.instance.addPostFrameCallback` inside the build when phase changes, or listen in
a `StatefulWidget`; either is fine, no double navigation). The End button also goes through the
confirm dialog.

### `SessionCompletePage`
Reads `session.record` (null-safe: if null, show "No session" and a Done button). Eyebrow
"SESSION COMPLETE" or "SESSION ENDED" (from `completed`), workout name in `displayLarge`, then
three stat cells like the detail page: rounds "{roundsCompleted}/{roundsPlanned}", minutes
`workMinutes`, type label. A `bodyMuted` line: "Rating and notes arrive with the journal."
Bottom `PillButton` "Done" (filled, 56) that calls `session.reset()` and
`Navigator.of(context).popUntil((r) => r.isFirst)`.

### `HomePage` (modify)
Under the existing header and line, add a `PillButton` "Start round timer" (filled, 56) that
calls `startSession(context, Workout.quick(rounds: 3, workSeconds: 180, restSeconds: 60))`,
and beneath it a `bodyMuted` line "Workouts live in the Train tab." Nothing else changes.

### Visual notes
- Group headers and eyebrows are uppercase `label`; never bold body text for emphasis.
- No shadows. Depth comes from `surface` vs `surfaceRaised` and `line` hairlines.
- Session page has no app bar; nothing but the content and the controls.

### docs/architecture.md
Module map rows for all new files; a "Navigation" paragraph: shell tabs in an `IndexedStack`,
detail and session pages pushed on the root navigator, session page is a fullscreen dialog
route that cannot be popped while active.

## Out of scope
- No post-session rating or notes (run 3), no history, no Home stats.
- No stance / difficulty pickers on the detail page.
- No landscape layout.
- No changes to providers or services.

## Acceptance criteria
- [ ] Train tab shows the quick timer card and twelve tiles under grouped headers; tapping a
      tile opens its detail page; "Start workout" opens the session page in prepare.
- [ ] Quick timer steppers clamp to their ranges and the summary updates.
- [ ] Session page: with a fake clock advanced through a 1-round, 5 s work, 0 s rest, 2 s
      prepare workout, the eyebrow reads "GET READY" then "ROUND 1 OF 1", the clock text goes
      "0:02" -> "0:05" -> "0:00", and the page ends on `SessionCompletePage` reading "1/1".
- [ ] Tapping the centre toggles pause (text "PAUSED" appears; button reads "Resume").
- [ ] System back while active shows the dialog; "Keep going" leaves the session running;
      "End" lands on the complete page with "SESSION ENDED".
- [ ] Every control on the session page has a hit box at least 64 dp tall.
- [ ] `flutter analyze` 0 issues; on the device the countdown is readable from 2 m.

## Verification
- Assistant tests: `test/pages/train_page_test.dart`, `test/pages/session_page_test.dart`,
  `test/widgets/quick_timer_card_test.dart`, `test/widgets/pill_button_test.dart`. Widget tests
  pump `MultiProvider` with real `SettingsProvider` (loaded over `setMockInitialValues({})`)
  and `SessionProvider(clock: () => now)`; advance `now` and `tester.pump(1 s)` together.
  Plugins are not in the tree (no `CueController` in tests), so no channel mocking is needed.
