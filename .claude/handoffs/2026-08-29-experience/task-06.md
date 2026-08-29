# Task 06 - Motion pass

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-05
- **Worker:** developer (Opus)
- **Tests:** yes (assistant, light)

## Goal
Micro-animations where they carry meaning: the clock breathes in the last ten seconds, phase
changes cross-fade their colour and flash the screen once, cues slide in, numbers count up,
badges and tiles settle in, buttons respond to touch. Everything respects the system's
reduce-motion setting and never fights the gym-legibility rules.

## Context the worker needs
- All pages and widgets from runs 1 to 5. `MediaQuery.disableAnimationsOf(context)` is the
  reduce-motion signal (verify the exact accessor in this Flutter version).
- Rule of thumb: one orchestrated moment per screen beats scattered effects. Durations short
  (150 to 400 ms), curves `Curves.easeOutCubic` for entrances, `easeInOut` for state changes.
  No bouncing, no parallax, nothing that loops except the two "ambient" items listed.

## Files
- `lib/theme/app_motion.dart` - create - `AppMotion` tokens.
- `lib/widgets/count_up_text.dart` - create.
- `lib/widgets/settle_in.dart` - create - `SettleIn` (entrance wrapper).
- `lib/widgets/pill_button.dart` - modify - press feedback.
- `lib/widgets/round_clock.dart`, `lib/widgets/cue_banner.dart`, `lib/pages/session_page.dart` - modify.
- `lib/widgets/stat_tile.dart`, `lib/widgets/milestone_badge.dart`, `lib/widgets/empty_state.dart`,
  `lib/widgets/reaction_arena.dart` - modify.
- `lib/pages/home_page.dart`, `lib/pages/train_page.dart`, `lib/pages/skills_page.dart`,
  `lib/pages/progress_page.dart`, `lib/pages/session_complete_page.dart`,
  `lib/pages/onboarding_page.dart` - modify (wrap sections in `SettleIn`, use `CountUpText`).
- `lib/theme/app_theme.dart` - modify - `pageTransitionsTheme`.
- `docs/architecture.md` - modify - rows and a "Motion" paragraph under Styling.

## Spec

### `AppMotion`
`static const Duration fast = 150 ms, base = 250 ms, slow = 400 ms, flash = 320 ms`;
`static const Curve enter = Curves.easeOutCubic, change = Curves.easeInOut`;
`static bool reduced(BuildContext)`; `static Duration of(BuildContext, Duration)` returning
`Duration.zero` when reduced. Stagger step `stagger = 40 ms`.

### `SettleIn`
`const SettleIn({required Widget child, int index = 0})`: on first build animates opacity 0 -> 1
and a 12 dp upward slide over `base`, delayed by `index * stagger` (cap at 8 steps). Uses
`TweenAnimationBuilder` (no controller to dispose); instant when reduced. Wrap page sections
(header, cards, tiles) in the pages listed, with ascending indexes. Do not wrap list items in
long lists beyond the first eight (the cap handles it, but pass `index` accordingly).

### `CountUpText`
`const CountUpText({required int value, required TextStyle style, String suffix = ''})`:
animates from the previously displayed value to `value` over `slow` with `tabular` figures
(`FontFeature.tabularFigures()`); instant when reduced. Used by `StatTile`, the complete
page's stat cells, and the Home streak strip's number.

### `PillButton`
Wrap in `AnimatedScale` to 0.97 while pressed (`Listener` or `InkWell` `onHighlightChanged`),
`fast`, `change` curve.

### Session screen
- `RoundClock`: colour changes cross-fade with `AnimatedDefaultTextStyle` (`base`); the
  progress bar animates its width (`AnimatedContainer`, 1 s linear, so it moves continuously
  between ticks); in the work phase with `secondsLeft <= 10`, an `AnimatedScale` pulse
  1.0 -> 1.04 -> 1.0 on each tick (`base`), none when reduced.
- `CueBanner`: `AnimatedSwitcher` transition becomes fade plus a 16 dp slide up (`base`,
  `enter`); the outgoing cue fades only.
- `SessionPage`: on `roundStarted` and `restStarted` (listen to `session.events` in the state,
  cancel in `dispose`) paint a full-screen overlay in the phase colour at 0.22 alpha that fades
  to 0 over `flash` (`AnimatedOpacity` toggled by a flag). Skipped when reduced.
- "PAUSED" label: `AnimatedOpacity` in/out over `fast`.

### Reaction arena
Background colour changes via `AnimatedContainer` (`fast`); the "GO" and arrow appear with an
`AnimatedScale` from 0.8 (`fast`), none when reduced (the timing of the stimulus itself is
unaffected: the colour flips immediately, only the glyph scales).

### Empty states and badges
`EmptyState`: the eyebrow gets a 6 dp `accent` dot before it that "breathes" (opacity 0.4 to
1.0, 1.6 s, repeat, `TweenAnimationBuilder` restarted via a `StatefulWidget` with an
`AnimationController` disposed properly); this is one of the two allowed loops. `MilestoneBadge`:
achieved badges `SettleIn` with a scale from 0.9; unachieved just fade.

### Home
The quote card is the second allowed loop: nothing loops on it; instead the streak flame icon
does a single `AnimatedScale` 1 -> 1.15 -> 1 on first build when `streakDays > 0`. (So only
the empty-state dot loops. Keep it that way.)

### Progress: the Journal link is a button (owner feedback, R3-05)
The `TextButton('Journal')` in the Progress header does not look tappable. Replace it: remove
the header `trailing`, and insert, directly under the `SectionHeader`, a `PillButton`
(outlined, height `minTapTarget`, icon `Icons.menu_book_rounded`) labelled "Journal", with a
small `Icons.chevron_right_rounded` at the end. Give `PillButton` an optional
`IconData? trailingIcon` for that; default null. Same affordance rule everywhere: anything
tappable is a pill, a tile, a switch or an icon button, never bare text. Sweep the pages for
other bare `TextButton`s used as navigation (Home's "See details" stays a `TextButton` but gets
an underline via `TextStyle(decoration: TextDecoration.underline)` in `chalkMuted`).

### Page transitions
`AppTheme.dark` gets `pageTransitionsTheme` with, for Android,
`FadeForwardsPageTransitionsBuilder` if it exists in this Flutter version, otherwise
`ZoomPageTransitionsBuilder` (verify in the SDK source; do not guess). The session route stays a
`fullscreenDialog`.

## Out of scope
- Lottie or Rive; new dependencies. Haptics tied to animations.
- Changing any layout, copy or colour, except the Progress Journal button and the underlined
  "See details" link specified above.

## Acceptance criteria
- [ ] With `MediaQuery(disableAnimations: true)` every listed animation is instant: a widget
      test pumps `SettleIn`, `CountUpText`, `CueBanner` and `RoundClock` and finds final values
      after a single frame.
- [ ] With animations on, `CountUpText` from 0 to 42 shows an intermediate value after 200 ms
      and 42 after 400 ms; `SettleIn(index: 2)` is still transparent at 50 ms and opaque by 400 ms.
- [ ] `RoundClock` pulses only when phase is work and `secondsLeft <= 10`.
- [ ] Progress shows an outlined "Journal" pill with the book icon and chevron under the header;
      tapping it opens `JournalPage`; no bare-text navigation remains except the underlined "See details".
- [ ] Device walkthrough (assistant, screenshots at 100 ms after actions): no jank visible in
      logcat ("Skipped frames" lines), no overflow.
- [ ] `flutter analyze` 0 issues; every `AnimationController` is disposed.

## Verification
- Assistant tests: `test/widgets/settle_in_test.dart`, `test/widgets/count_up_text_test.dart`,
  extend `round_clock` / `cue_banner` tests; then a device walkthrough with `adb logcat -d |
  grep -c "Skipped"` before and after a session.
