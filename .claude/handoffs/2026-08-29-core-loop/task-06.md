# Task 06 - Review round 1 fixes

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** task-05
- **Worker:** developer (Opus)
- **Tests:** yes (developer: adjust the existing tests named below)

## Goal
Three small corrections from the Architect's review of tasks 01 to 05 (`docs/review-log.md`
R1-01 to R1-03). No new behaviour beyond what is listed.

## Context the worker needs
- `lib/providers/session_provider.dart` `resume()`, `lib/utils/cue_speech.dart`,
  `lib/services/cue_controller.dart` constructor, `lib/services/audio_service.dart`.
- Existing tests: `test/providers/session_provider_test.dart`, `test/utils/cue_speech_test.dart`,
  `test/services/cue_controller_test.dart`.

## Files
- `lib/providers/session_provider.dart` - modify - `resume()` only.
- `lib/utils/cue_speech.dart` - modify - hyphen handling.
- `lib/services/cue_controller.dart` - modify - constructor.
- `test/providers/session_provider_test.dart`, `test/utils/cue_speech_test.dart`,
  `test/services/cue_controller_test.dart` - modify - add or adjust the cases below.

## Spec

### R1-01 `resume()` keeps the phase length
Today `resume()` sets `_phaseSeconds = _secondsLeft`, so `phaseSeconds` shrinks and the
`RoundClock` progress bar snaps back to empty after every pause. Instead keep `_phaseSeconds`
and move the deadline: `_phaseStartedAt = now.subtract(Duration(seconds: _phaseSeconds - _secondsLeft))`.
`secondsLeft` continues from the paused value exactly as before. Update the `phaseSeconds`
doc comment if it mentions the old behaviour. Test: after `pause()` at 40 s left in a 60 s
round and `resume()`, `phaseSeconds` is still 60 and `secondsLeft` is 40, then 39 one tick later.

### R1-02 `cueToSpeech` only expands hyphens inside punch chains
`cue.replaceAll('-', ', ')` turns the library's `push-ups`, `pull-ups` and `med-ball slams`
into "push, ups". Change the algorithm: split on spaces; for each word (keeping a trailing
comma aside), split on `-`; if every part is a punch token (`[1-6]` with optional `b`),
join the spoken parts with `, `; otherwise return the word unchanged. Keep every existing
case passing (`'1-2, slip, pivot, exit'` -> `'jab, cross, slip, pivot, exit'`, `'3b'` ->
`'lead hook to the body'`, `''` -> `''`). New cases: `'push-ups'` -> `'push-ups'`,
`'rows or pull-ups'` unchanged, `'1-2b-2'` -> `'jab, cross to the body, cross'`.

### R1-03 Audio is initialised up front
`AudioService.init()` runs lazily inside the first `_play`, so the first sound of a session
(the prepare beep or the opening bell) pays the audio-context setup. In the `CueController`
constructor call `unawaited(audio.init())` next to `unawaited(voice.init())`. Test: the fake
audio service in `cue_controller_test.dart` records an `init` call on construction (add the
override if the fake lacks it).

## Out of scope
- Anything else in those files. No UI changes.

## Acceptance criteria
- [ ] The three tests above pass and the rest of the suite stays green.
- [ ] `flutter analyze` 0 issues; `dart format` on touched files.

## Verification
`flutter test`, `flutter analyze`.
