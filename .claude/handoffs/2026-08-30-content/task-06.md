# Task 06 - Reaction drills 3: four speed drills

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-05
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Four more reaction modes that train speed, two with boxing context and two without:
**Peripheral** (a dot appears somewhere on the screen, tap it), **Colour call** (a colour word
in a mismatching ink, tap the ink colour, not the word), **Sequence** (two to four arrows flash,
reproduce them in order), **Sound** (screen stays dark, react to the beep). All work in both
formats and save like the others.

## Context the worker needs
- `ReactionProvider`, `ReactionMode`, `ReactionArena`, `ReactionPage`, `DefenseGrid`,
  `ReactionResult`, `AudioService` (`playTick`), `main.dart` provider list.
- Services in the tree: only `VoiceService` and `NotificationService` are exposed as plain
  `Provider`s. This task adds `Provider<AudioService>.value` for the Sound mode's beep (the
  page plays it when the provider enters `stimulus`).

## Files
- `lib/models/reaction_mode.dart` - modify - four values.
- `lib/models/reaction_colour.dart` - create - `ReactionColour` (red, mint, amber, chalk).
- `lib/providers/reaction_provider.dart` - modify.
- `lib/widgets/reaction_arena.dart` - modify.
- `lib/widgets/colour_grid.dart` - create.
- `lib/widgets/sequence_pad.dart` - create.
- `lib/pages/reaction_page.dart` - modify - eight mode cards in two groups; sound playback.
- `lib/main.dart` - modify - `Provider<AudioService>.value`.
- `docs/architecture.md` - modify.

## Spec

### Modes
`ReactionMode { tap, direction, defense, goNoGo, peripheral, colour, sequence, sound }` with
labels "Peripheral", "Colour call", "Sequence", "Sound" and descriptions "A dot appears
anywhere. Tap it.", "Tap the ink colour, not the word.", "Watch the arrows, then tap them
back in order.", "Screen dark. Tap when you hear the beep." Grouping for the picker: `bool
get isBoxing` true for defense and goNoGo and sequence (arrows as footwork directions), false
for the rest; the picker shows two eyebrows, "BOXING" and "PURE SPEED".

### Provider additions
- `Offset? get dotPosition` (peripheral; fractions 0.1 to 0.9 in both axes, chosen with
  `random` at stimulus). `tap({..., Offset? at})`: a hit when `at` is within 0.09 of
  `dotPosition` in normalised units, else a miss "Missed it".
- `ReactionColour get inkColour`, `ReactionColour get wordColour` (colour mode; always
  different). `tap({..., ReactionColour? colour})`: hit when `colour == inkColour`, else
  miss "Wrong colour".
- `List<ReactionDirection> get sequence` (2 arrows on trials 1 to 3, 3 on 4 to 7, 4 after;
  endurance: grows every 3 trials, capped at 4). Sequence trials have an extra sub-phase: the
  provider shows the arrows for `600 ms * length` (`ReactionPhase.stimulus` with
  `bool get isShowingSequence == true`), then hides them and starts the clock
  (`isShowingSequence == false`); the boxer taps directions in order via
  `tap(direction:)`. Wrong entry -> miss "Wrong order". Complete -> hit with the time from
  the clock start to the last tap. Timeout 2 s per arrow.
- Sound: identical to tap mode in the provider (`isGo` true), plus `bool get isSoundMode`;
  the page listens for the transition to `stimulus` and calls `audio.playTick()`; the arena
  stays `ink` with a small `chalkFaint` ring pulsing (`AppMotion`) during waiting so the boxer
  knows it is live.

### Widgets
- `ColourGrid`: four zones (2 x 2) filled with the four `ReactionColour`s at 0.85 alpha with
  the colour name in `label` (`ink` on chalk and amber, `chalk` on red and mint); centre text
  the word in `displayHero` painted in the ink colour, `IgnorePointer`.
- `SequencePad`: the existing four-edge direction layout from direction mode, reused; when
  `isShowingSequence` the arrows render in the centre in a `Row`, else the centre shows a
  progress of dots (filled per correct tap).
- Peripheral: a full-arena `GestureDetector` with `onTapDown` mapping the local position to
  fractions; the dot is a 44 dp `accent` circle at `dotPosition`.

### Results and Progress
`ReactionResult` needs no new fields. Progress per-mode tiles pick up the new modes
automatically (up to eight tiles: switch the `Row` to a `Wrap` with 3 per line).

## Out of scope
- Ears-only with spoken punches, two-player, rhythm, custom presets (rejected earlier).

## Acceptance criteria
- [ ] Each new mode runs ten trials and completes with a result under `FakeAsync` and a fake
      clock: peripheral hit within radius, miss outside; colour hit on ink colour, miss on
      word colour; sequence correct order hit, wrong order miss, timeout miss; sound behaves as
      tap.
- [ ] Endurance works for all four.
- [ ] Picker shows eight cards under two eyebrows; Sound mode plays a tick on stimulus (fake
      `AudioService` records one `playTick` per stimulus).
- [ ] Progress renders up to eight mode tiles without overflow.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: extend `reaction_provider_test.dart` (four groups), `reaction_page_test.dart`,
  `progress_page_test.dart`; `test/widgets/colour_grid_test.dart`, `test/widgets/sequence_pad_test.dart`.
