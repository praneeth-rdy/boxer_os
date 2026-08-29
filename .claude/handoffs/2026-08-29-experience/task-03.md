# Task 03 - Combos 2.0 screens: library, saved, practice

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The Combos page becomes three views: Generate (today's screen plus a bookmark), Library (the
sixty combinations, filterable by difficulty and style, each opening a detail sheet with the
spoken breakdown and a practice button), and Saved (bookmarks that survive a restart, with a
practice session built from them).

## Context the worker needs
- `lib/pages/combos_page.dart` (run 2), `combinationLibrary`, `combinationsWhere`,
  `Combination` metadata (task-02), `startSession`, `SettingsProvider`, `PillButton`,
  `StepperRow`, `SkillCard` styling, the `segmentedButtonTheme`.
- Prefs rule: keys live as `static const` on the provider that owns them.

## Files
- `lib/providers/combos_provider.dart` - create - `CombosProvider`.
- `lib/widgets/combo_tile.dart` - create - `ComboTile`.
- `lib/widgets/combo_sheet.dart` - create - `showComboSheet`.
- `lib/widgets/filter_chip_row.dart` - create - `FilterChipRow`.
- `lib/utils/practice_builder.dart` - create - `buildPracticeWorkout`.
- `lib/pages/combos_page.dart` - rewrite - the three views.
- `lib/main.dart` - modify - create, load and provide `CombosProvider`.
- `docs/architecture.md` - modify - rows, prefs key.

## Spec

### `CombosProvider`
Key `savedKey = 'saved_combinations'`: JSON list of `Combination.toJson()` (library entries
are stored in full too, so a renamed library entry still shows what was saved). API:
`load()`, `List<Combination> get saved` (insertion order, unmodifiable), `bool isSaved(Combination)`
(by the equality from task-02), `Future<void> toggleSaved(Combination)`, `Future<void> remove(Combination)`,
`error`. Persist after each change; failures set `error`, keep memory state.

### `buildPracticeWorkout` (`lib/utils/practice_builder.dart`)
```dart
Workout buildPracticeWorkout({
  required List<Combination> combinations, required int rounds, required int roundSeconds,
  required Difficulty difficulty, String name = 'Combo practice',
});
```
Cues every 20 s from second 3 (`< roundSeconds - 5`), cycling through `combinations` in order
across all rounds (round 2 continues where round 1 stopped), `restSeconds: 45`,
`focus: 'Combo round n'`, `type: shadowBoxing`, `isCustom: true`, `id: 'combo_practice'`.
Empty `combinations` -> a workout with focus only and no cues (never throws). Move the
existing practice-building code out of `combos_page.dart` into this function.

### `ComboTile`
`const ComboTile({required Combination combination, required bool isSaved, required VoidCallback onTap, required VoidCallback onToggleSaved})`.
`surface` card, `radiusMd`, min 72 dp: notation in `displaySmall`, name in `body` (generated
combinations show `spoken` instead), tags and difficulty in `caption` ("Counter · Body ·
Intermediate"); trailing 48 dp icon button `Icons.bookmark_rounded` (accent when saved) /
`Icons.bookmark_border_rounded`.

### `showComboSheet(BuildContext, Combination)`
`showModalBottomSheet` on `surfaceRaised`, `radiusLg` top corners, drag handle: notation in
`displayLarge` (`FittedBox`), name in `title` (if any), description in `bodyMuted`, "SPOKEN"
eyebrow + `spoken` in `body`, tag chips, then two `PillButton`s: "Practice this" (filled,
56) -> `buildPracticeWorkout(combinations: [c], rounds: 3, roundSeconds: 120, ...)` and
`startSession`; "Save" / "Saved" (outlined) toggling the bookmark.

### `FilterChipRow`
`const FilterChipRow<T>({required List<T> values, required T? selected, required String Function(T) label, required ValueChanged<T?> onSelected, String allLabel = 'All'})`.
Horizontal scroll of `ChoiceChip`s styled from the theme (add a `chipTheme` to
`AppTheme.dark`: `surface` background, `accent` at 0.18 alpha selected with `chalk` label,
`line` border, `radiusPill`, label `label` style; the one permitted theme edit). First chip is
"All" (`null`).

### `CombosPage` (rewrite)
Top: `SectionHeader(title: 'Combos', eyebrow: 'COMBINATION LAB')`, then a
`SegmentedButton<ComboView>` (`enum ComboView { generate, library, saved }`, labels Generate /
Library / Saved) kept in page state.
- Generate: today's content (difficulty segments, card, New combo, practice steppers), plus a
  bookmark icon button in the card's top-right corner toggling `CombosProvider`.
- Library: two `FilterChipRow`s (difficulty; tag), then `ComboTile`s for
  `combinationsWhere(...)`, tap -> `showComboSheet`. Difficulty filter defaults to the
  settings difficulty (not "All").
- Saved: if empty, an empty state: eyebrow "NOTHING SAVED YET", `displayMedium` "Bookmark the
  ones you want to drill", `bodyMuted` "Tap the bookmark on any combination. Saved combos become
  a practice session here." and a ghost `PillButton('Browse the library')` switching the
  segment. Otherwise `ComboTile`s (toggle removes), then the practice steppers (rounds 1..12,
  length 60..300) and `PillButton('Practice saved', filled, 56)` ->
  `buildPracticeWorkout(combinations: saved, ...)` -> `startSession`.

### `main.dart`
`final combos = CombosProvider(); await combos.load();` provided with `ChangeNotifierProvider.value`.
`BoxerOsApp` gains the parameter; fix `test/pages/app_shell_test.dart` accordingly.

## Out of scope
- Sharing, ordering or renaming saved combos. Saving generated workouts as library entries.

## Acceptance criteria
- [ ] `CombosProvider` persists a toggle to `saved_combinations` and reloads it; `isSaved`
      matches a library entry by id and a generated one by moves.
- [ ] `buildPracticeWorkout` with 2 combos and 2 x 60 s rounds yields cues at 3, 23, 43 in
      each round cycling A, B, A / B, A, B.
- [ ] Library view lists 15 tiles for beginner, filters by tag, opens the sheet; Save toggles
      the icon; Saved view shows the empty state then the saved tile; "Practice saved" opens the
      session page.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/providers/combos_provider_test.dart`, `test/utils/practice_builder_test.dart`,
  `test/pages/combos_page_test.dart` (rewrite), `test/widgets/combo_tile_test.dart`.
