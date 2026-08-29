# Task 03 - Home and Settings

- **Run:** `.claude/handoffs/2026-08-29-memory/`
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Home becomes the command centre: a greeting, the streak and the weekly snapshot, today's
recommended session with a one-tap start, and quick actions for the timer, combos and
reaction. A Settings page (gear on Home) exposes stance, difficulty, the cue toggles, keep
screen on, About with the version, and a clear-history action.

## Context the worker needs
- `HistoryProvider`, `TrainingStats`, `StatTile` from tasks 01 and 02; `workoutLibrary`,
  `workoutsOfType`, `findWorkout`, `Workout.quick`, `startSession`; `CombosPage`,
  `ReactionPage` from run 2; `SettingsProvider`.
- `docs/product.md` "Answered questions" 5 (recommendation rule) and "Core loop".

## Files
- `lib/utils/recommendation.dart` - create - `recommendWorkout`.
- `lib/widgets/quick_action.dart` - create - `QuickAction`.
- `lib/pages/home_page.dart` - rewrite.
- `lib/pages/settings_page.dart` - create.
- `docs/architecture.md` - modify - rows and navigation.

## Spec

### `recommendWorkout(TrainingStats stats, Difficulty difficulty, {required DateTime now})` -> `Workout`
Pure. Candidate types in this order: shadow boxing, heavy bag, footwork, conditioning, mitt
work, speed bag, strength. Pick the type whose `lastTrainedByType` entry is oldest (a type
never trained counts as oldest, ties broken by the order above). Among `workoutsOfType(type)`
pick the one whose difficulty equals `difficulty`, else the closest (beginner -> intermediate
-> advanced distance), else the first. Sparring is never recommended (it needs a partner).
With no history at all this yields `shadow_foundations` for beginners.

### `QuickAction`
`const QuickAction({required String label, required IconData icon, required VoidCallback onTap})`:
a `surfaceRaised` square card (`radiusMd`, min 88 dp tall), icon 28 `chalk` over label in
`label`. Three of them fill a `Row` with `spaceSm` gaps.

### `HomePage` (rewrite, `Consumer2<HistoryProvider, SettingsProvider>`)
`ListView` padded `spaceLg`:
1. `SectionHeader(title: greeting, eyebrow: 'BOXER OS', trailing: IconButton(Icons.settings_rounded)
   -> SettingsPage)`. Greeting by hour: before 12 "Morning, fighter", before 18 "Afternoon,
   fighter", else "Evening, fighter".
2. Streak strip: a `surface` card with `Icons.local_fire_department_rounded` (`accent` when
   `streakDays > 0`, `chalkFaint` otherwise), "{streakDays} day streak" in `title` (or "No
   streak yet. Today is a good day." in `bodyMuted` when 0), and on the right "{weekRounds}
   rounds · {weekMinutes} min this week" in `caption`.
3. Eyebrow "TODAY'S SESSION", a `surface` card, padding `spaceLg`: the recommended workout's
   type + difficulty uppercase in `label`, name in `displayMedium`, "{roundCount} x
   {formatClock(work)} · {estimatedMinutes} min" in `bodyMuted`, then `PillButton('Start',
   filled, 56)` -> `startSession(context, workout)`, and a ghost `TextButton` "See details"
   -> `WorkoutDetailPage`.
4. Eyebrow "QUICK ACTIONS", `Row` of three `QuickAction`s: Timer (`Icons.timer_rounded`,
   starts `Workout.quick(rounds: 3, workSeconds: 180, restSeconds: 60)`), Combos
   (`Icons.sports_mma_rounded`, pushes `CombosPage`), Reaction (`Icons.flash_on_rounded`, pushes
   `ReactionPage`).
5. If `history.sessions` is non-empty: eyebrow "LAST SESSION" and a `SessionTile` for
   `sessions.first` pushing `SessionDetailPage`.

### `SettingsPage`
Transparent app bar with back; `ListView` padded `spaceLg`; `SectionHeader(title: 'Settings',
eyebrow: 'FIGHTER PROFILE')`. Sections, each an eyebrow plus content:
- "STANCE": `SegmentedButton<Stance>` -> `setStance`.
- "LEVEL": `SegmentedButton<Difficulty>` -> `setDifficulty`.
- "CUES": four `SwitchListTile`s styled from the theme (add a `switchTheme` to `AppTheme.dark`:
  thumb `chalk`, track `accent` when selected and `line` otherwise; the one permitted theme
  edit): Sound, Haptics, Voice, Keep screen on during sessions, bound to the four setters.
  Title in `body`, subtitle in `caption` ("Bells and beeps", "Buzz on round changes", "Spoken
  cues and combinations", "Uses more battery").
- "DATA": a `PillButton('Clear history', outlined)` -> `AlertDialog` "Delete all sessions and
  reaction results? This cannot be undone." with Cancel / Delete -> `history.clearAll()`.
- "ABOUT": "Boxer OS {AppTheme.appVersion}" in `body`, "Local-first. Nothing leaves your
  phone." in `bodyMuted`.

### docs/architecture.md
Rows; navigation gains Settings; the recommendation rule in one line under Layers.

## Out of scope
- No new prefs keys. No profile fields beyond stance and level. No notifications.

## Acceptance criteria
- [ ] `recommendWorkout` with empty stats and beginner returns `shadow_foundations`; after a
      shadow session today it returns a heavy-bag workout; sparring never appears; the
      difficulty preference is honoured when a match exists.
- [ ] Home shows the greeting, the streak strip with correct numbers, the recommended card,
      three quick actions; Start opens the session page.
- [ ] Settings toggles call the matching setters and persist; Clear history empties the
      provider after confirmation.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/utils/recommendation_test.dart`, `test/pages/home_page_test.dart`,
  `test/pages/settings_page_test.dart`.
