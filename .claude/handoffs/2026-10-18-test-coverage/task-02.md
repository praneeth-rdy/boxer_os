# Task 02 - tests for the models and data constants that carry logic

- **Run:** `.claude/handoffs/2026-10-18-test-coverage/`
- **Depends on:** none
- **Worker:** assistant (Sonnet)
- **Tests:** yes (assistant)

## Goal
The untested models gain tests where they actually do something: JSON round-trips, the
`fromName` fallbacks that protect against a bad prefs value, enum labels the UI depends on, and
any derived getter.

## Context the worker needs
- `.claude/CLAUDE.md`, **Tests**: behaviour names, arrange / act / assert, one behaviour per test.
- `test/models/workout_test.dart` and `test/models/session_record_test.dart` show the house
  pattern for JSON round-trips. `test/models/stance_test.dart` shows it for an enum with a
  `fromName`. Follow them.
- The standing rule in `plan.md`: no test that only re-asserts a constructor.

## Files
Create, under `test/models/` unless noted:
- `round_cue_test.dart`, `training_type_test.dart`, `reaction_format_test.dart`,
  `reaction_direction_test.dart`, `incoming_punch_test.dart`, `poster_test.dart`,
  `boxing_event_test.dart`, `legend_test.dart`, `wall_photo_test.dart`, `milestone_test.dart`
- `test/data/app_identity_test.dart`
- (only these; `lib/` is out of scope)

## Spec
Read each `lib/` file before writing its test. Cover, per file, only what has logic:

- `models/round_cue.dart`: `toJson` emits the keys `at` and `text`; `fromJson` reads them;
  a round-trip preserves both fields; `fromJson` on a malformed map behaves as the code says
  (read it, then assert what it actually does, do not assume it throws).
- `models/training_type.dart` and `models/reaction_format.dart`: `fromName` returns the matching
  value for a valid name, and the documented fallback for `null` and for an unknown string.
  That fallback is the whole point of the method: assert it explicitly.
- `models/poster.dart`: the `PosterKind` labels ("Taglines", "Legends", "Moments",
  "Inspiration", "Quotes"), and any derived getter on `Poster`.
- `models/boxing_event.dart`: `EventKind` values, and any date matching or formatting the class
  does. If the class is a plain holder, assert only the `EventKind` surface and say so.
- `models/legend.dart`: the nested `PhotoCredit`, `GalleryPhoto` and `StorySection` types and any
  getter on `Legend` that derives something (an asset path, a count, a first section).
- `models/wall_photo.dart`, `models/milestone.dart`, `models/incoming_punch.dart`,
  `models/reaction_direction.dart`: cover the derived members only.
- `data/app_identity.dart`: whatever constants it exposes. If it carries the app version string,
  assert it matches the `version` in `pubspec.yaml`, which `.claude/CLAUDE.md` requires to stay
  in step. Read `pubspec.yaml` in the test rather than hard-coding the number twice.

Any file in the list that turns out to hold no logic: skip it, create no file for it, and name it
in NOTES. That is a correct outcome, not a failure.

## Out of scope
- Any edit under `lib/`.
- The library-content files already covered (`test/data/legends_test.dart`,
  `posters_test.dart`, `wall_photos_test.dart` and friends). Test the model types here, not the
  bundled content.

## Acceptance criteria
- [ ] Every `fromName` fallback in the list has an explicit null case and unknown-string case.
- [ ] `RoundCue` has a JSON round-trip test.
- [ ] No test asserts only that a constructor assigned a field.
- [ ] Files skipped for having no logic are named in NOTES.
- [ ] `flutter test` passes; `flutter analyze` introduces no new issues.

## Verification
`flutter test test/models test/data`, then `flutter analyze`, then `dart format` on the files you created.
