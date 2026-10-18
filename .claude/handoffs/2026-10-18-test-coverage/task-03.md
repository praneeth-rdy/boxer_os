# Task 03 - widget tests for ReactionArena

- **Run:** `.claude/handoffs/2026-10-18-test-coverage/`
- **Depends on:** none
- **Worker:** assistant (Sonnet)
- **Tests:** yes (assistant)

## Goal
`lib/widgets/reaction_arena.dart` is the largest untested file in the repo at 333 lines and the
surface the boxer taps during every reaction drill. It gains a widget test per mode it renders.

## Context the worker needs
- `ReactionArena` is a `StatelessWidget` taking a `ReactionProvider reaction` and a
  `ReactionTap onTap`. It switches on the provider's mode and renders a different field each
  time (`_PeripheralField`, `_PulseRing`, `_PopIn` are private pieces of it).
- `test/pages/reaction_page_test.dart` and `test/providers/reaction_provider_test.dart` already
  drive this provider. Reuse their setup rather than inventing one.
- `.claude/CLAUDE.md`, **Tests**: drive timers with `FakeAsync` or `tester.pump(duration)`, never
  a real delay. The arena animates, so pump explicit durations and avoid `pumpAndSettle` on
  anything that loops.
- The standing rule in `plan.md`.

## Files
- `test/widgets/reaction_arena_test.dart` - create
- (only this file; `lib/` is out of scope)

## Spec
Read `lib/widgets/reaction_arena.dart` and `lib/providers/reaction_provider.dart` first, then
cover:
- each `ReactionMode` the arena branches on renders its own field, and does not render the others.
  Drive the mode through the real `ReactionProvider`, the way `reaction_page_test.dart` does.
- a tap on the active target invokes `onTap` with the arguments the signature declares; a tap in
  a dead area of the arena does not.
- the Go / No-go distinction: tapping a no-go target reports it as such rather than as a hit.
  Assert whatever the real `ReactionTap` signature expresses; read it, do not assume.
- the peripheral mode positions its dot from the provider's offset rather than at the centre.
- a reduce-motion pass: with `MediaQuery.disableAnimations` true the arena still renders and
  still reports taps.

If a mode cannot be driven without changing `lib/`, leave it out and name it in NOTES.

## Out of scope
- Any edit under `lib/`.
- Re-testing `ReactionProvider`'s own scoring and timing, already covered by
  `test/providers/reaction_provider_test.dart`. Test the widget.
- Golden-image tests. This repo has none and this is not the task to start them.

## Acceptance criteria
- [ ] One test per `ReactionMode` the arena renders, each asserting the right field is shown.
- [ ] Tap wiring is covered, including a tap that must not register.
- [ ] One reduce-motion test.
- [ ] No real `Future.delayed` or wall-clock wait anywhere in the file.
- [ ] `flutter test` passes; `flutter analyze` introduces no new issues.

## Verification
`flutter test test/widgets/reaction_arena_test.dart`, then `flutter analyze`, then `dart format` on the file.
