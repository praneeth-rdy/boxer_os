# Task 01 - Skills hub and the combination generator

- **Run:** `.claude/handoffs/2026-08-29-skills/`
- **Depends on:** run 1 complete
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The Skills tab becomes a hub of three cards (Combos, Reaction, Footwork) and the Combos card
opens a combination generator: pick a difficulty, get a boxing-correct combination in the
notation the whole app uses, regenerate as often as you like, and start a practice session in
which the generated combinations are spoken round by round. Combinations are seeded, so a
boxer can repeat the same drill.

## Context the worker needs
- Cue notation and its rules: `.claude/handoffs/2026-08-29-core-loop/task-02.md` "Cue notation".
  `lib/utils/cue_speech.dart` (`cueToSpeech`) turns notation into speech; reuse it for the
  spoken preview.
- `lib/utils/session_launcher.dart` `startSession(context, workout)` opens the session screen.
- `lib/providers/settings_provider.dart` holds `difficulty` and `setDifficulty`.
- `lib/widgets/stepper_row.dart`, `lib/widgets/pill_button.dart`, `lib/widgets/section_header.dart`.
- Stance never changes the notation: `1` is always the lead hand, so orthodox and southpaw
  boxers read the same combination. No stance branching anywhere in this package.

## Files
- `lib/data/boxing_vocabulary.dart` - create - move vocabulary per difficulty.
- `lib/models/combination.dart` - create - `Combination`.
- `lib/utils/combination_generator.dart` - create - `generateCombination`, `generateCombinationSet`.
- `lib/widgets/skill_card.dart` - create - `SkillCard`.
- `lib/pages/skills_page.dart` - rewrite - the hub.
- `lib/pages/combos_page.dart` - create - the generator screen.
- `docs/architecture.md` - modify - module map rows.

## Spec

### Vocabulary (`lib/data/boxing_vocabulary.dart`)
Top-level `const` lists of notation tokens:
- `leadPunches = ['1', '3', '5']`, `rearPunches = ['2', '4', '6']`, `bodyPunches = ['1b', '2b', '3b']`.
- `beginnerPunches = ['1', '2', '3']`, `beginnerDefense = ['slip', 'step back']`.
- `intermediatePunches = ['1', '2', '3', '4', '5', '6', '2b', '3b']`,
  `intermediateDefense = ['slip', 'roll', 'pull', 'pivot', 'step back']`.
- `advancedPunches = intermediatePunches + ['1b']`,
  `advancedDefense = intermediateDefense + ['parry', 'slip left', 'slip right']`,
  `advancedExits = ['exit', 'pivot', 'circle left', 'circle right']`.
- `bool isPunch(String token)` (digit 1..6 with optional `b`), `bool isLeadHand(String token)`
  (`1`, `3`, `5`, `1b`, `3b`), `bool isBodyShot(String token)`.

### `Combination` (`lib/models/combination.dart`)
`const Combination({required List<String> moves, required Difficulty difficulty, required int seed})`.
`String get notation`: consecutive punches joined with `-`, everything else separated by `, `
(`['1','2','slip','3','2'] -> '1-2, slip, 3-2'`; `['1','2','pivot'] -> '1-2, pivot'`).
`String get spoken => cueToSpeech(notation)`. `int get punchCount`. `toJson` / `fromJson`
(`moves`, `difficulty` by name, `seed`), `==` / `hashCode` on all three fields.

### Generator (`lib/utils/combination_generator.dart`)
```dart
Combination generateCombination({required Difficulty difficulty, required int seed});
List<Combination> generateCombinationSet({required Difficulty difficulty, required int seed, required int count});
```
Pure, deterministic: `Random(seed)`; the set uses seeds `seed + index`. Rules:
- Length: beginner 2 to 3 moves, intermediate 3 to 4, advanced 4 to 6.
- First move is a punch. Beginner: punches only, except a 30% chance of ending
  `..., slip` or `..., step back` after a 2-punch chain (so `1-2, slip` is possible).
- Punch chains alternate hands with 80% probability (after a lead punch prefer a rear one and
  vice versa); the only allowed same-punch repeat is `1-1`. A body shot is never last in a chain
  of 3 or more and is always followed by a head punch.
- Intermediate: exactly one defense move, never first, never last (`1-2, slip, 3-2`).
- Advanced: one or two defense moves (never first, never adjacent), and a 50% chance the
  combination ends with an exit token from `advancedExits`.
- Punches come from the difficulty's punch list, defenses from its defense list. Never produce
  an empty combination; never exceed 6 moves.

### `SkillCard` (`lib/widgets/skill_card.dart`)
`const SkillCard({required String title, required String description, required IconData icon, required VoidCallback? onTap})`.
`surface` card, `radiusLg`, padding `spaceLg`, min height 96: icon (28, `accent`) on the left,
then title in `titleLarge` and description in `bodyMuted`; chevron `Icons.chevron_right_rounded`
in `chalkFaint` on the right. When `onTap` is null the card is at 0.5 alpha and shows "SOON"
in `label` instead of the chevron.

### `SkillsPage` (rewrite)
`ListView` with `SectionHeader(title: 'Skills', eyebrow: 'COMBOS, REACTION, FOOTWORK')` and three
`SkillCard`s separated by `spaceMd`:
- Combos, "Generate combinations and drill them with spoken cues.", `Icons.sports_mma_rounded`,
  pushes `CombosPage`.
- Reaction, "Test and train your reaction time.", `Icons.flash_on_rounded`, `onTap: null`
  (task-02 wires it).
- Footwork, "Movement drills on the round timer.", `Icons.directions_run_rounded`, `onTap: null`
  (task-03 wires it).

### `CombosPage` (`StatefulWidget`)
State: `Difficulty difficulty` (initialised from `SettingsProvider.difficulty`), `int seed`
(initialised from `Random().nextInt(0xFFFF)`), `int practiceRounds = 3`,
`int practiceRoundSeconds = 120`. `Combination get combination =>
generateCombination(difficulty: difficulty, seed: seed)`.
Layout: `Scaffold`, transparent `AppBar` (back only), `ListView` padded `spaceLg`:
1. `SectionHeader(title: 'Combos', eyebrow: 'COMBINATION GENERATOR')`.
2. `SegmentedButton<Difficulty>` with the three labels, selected = `difficulty`; on change set
   state and call `settings.setDifficulty`. Style it through the theme: add a
   `segmentedButtonTheme` to `AppTheme.dark` (selected: `accent` background / `onAccent` text;
   unselected: `surface` background / `chalkMuted` text; `line` border; `radiusPill`; min height
   `minTapTarget`). This is the one permitted `AppTheme` edit.
3. A `surface` card, `radiusLg`, padding `spaceLg`, min height 200, centred: `notation` in
   `displayLarge` (`FittedBox` scaleDown, max 2 lines), `spaceMd`, `spoken` in `bodyMuted`
   centred, `spaceSm`, `'#' + seed.toRadixString(16).toUpperCase().padLeft(4, '0')` in
   `caption`.
4. `PillButton('New combo', filled, 56)` sets a fresh random seed.
5. `spaceXl`, eyebrow "PRACTICE", two `StepperRow`s: Rounds (1..12, step 1) and Round length
   (60..300 s, step 30, shown with `formatClock`), then a `bodyMuted` line
   "{rounds} rounds, a new combination every 20 seconds", then
   `PillButton('Start practice', outlined, 56)` which builds and starts:
   `Workout(id: 'combo_practice', name: 'Combo practice', type: TrainingType.shadowBoxing,
   difficulty: difficulty, isCustom: true, rounds: [...])` where round `r` (0-based) has
   `workSeconds: practiceRoundSeconds`, `restSeconds: 45`, `focus: 'Combo round ${r + 1}'`, and
   cues at seconds 3, 23, 43, ... (`< workSeconds - 5`) whose texts are the notations of
   `generateCombinationSet(difficulty, seed: seed + r * 100, count: cueCount)`; the first cue
   of round 1 is the combination on screen. Then `startSession(context, workout)`.

### docs/architecture.md
Rows for the six files; a line under "Bundled data" for the vocabulary; a sentence in
"Navigation" for the Skills hub pushing `CombosPage`.

## Out of scope
- Reaction trainer and footwork (tasks 02, 03).
- Speaking a combination from this page without a session (services are not in the widget tree).
- Persisting generated combinations or practice results (run 3 history covers sessions).

## Acceptance criteria
- [ ] `generateCombination` with the same difficulty and seed returns equal combinations; two
      different seeds usually differ (test 20 seeds, expect at least 15 distinct notations).
- [ ] Over 200 seeds per difficulty: every combination starts with a punch, lengths are within
      range, beginner uses only `1`, `2`, `3` plus at most one trailing defense, intermediate
      has exactly one defense that is neither first nor last, advanced has 1 or 2 non-adjacent
      defenses, no body shot is immediately followed by another body shot, and the only
      repeated adjacent punch is `1-1`.
- [ ] `Combination(moves: ['1','2','slip','3','2']).notation == '1-2, slip, 3-2'` and
      `.spoken == 'jab, cross, slip, lead hook, cross'`; JSON round-trips.
- [ ] Skills tab shows three cards, two marked SOON; Combos opens the generator; "New combo"
      changes the seed; the segmented control persists the difficulty to `SettingsProvider`.
- [ ] "Start practice" opens the session page with a 3-round shadow-boxing workout whose
      round 1 first cue equals the displayed notation.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/utils/combination_generator_test.dart`,
  `test/models/combination_test.dart`, `test/pages/skills_page_test.dart`,
  `test/pages/combos_page_test.dart` (pump with real providers; `Random` seeds are page-local,
  so assert structure, not values).
