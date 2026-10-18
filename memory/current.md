# Current state

Last updated 2026-10-18, Codex setup.

## Where the project stands

V1 and the memory, CI and test-coverage work are committed on `main`. HEAD at session start:
`1fee6fe` (retire the old Claude memory). The working tree was clean.

Uncommitted in this session:

- `.codex/config.toml` and `.codex/README.md`: repository defaults and setup instructions.
- `AGENTS.md`: Codex workflow using the existing shared conventions and memory.
- `README.md` and `docs/README.md`: Codex setup pointers.
- This snapshot and the work-log entry.

Last recorded application checks: `flutter analyze` 0 issues, `flutter test` 730/730 and
`dart format` clean (earlier 2026-10-18 session). Application checks were not rerun for this
configuration and documentation change.

## In flight

Nothing. Codex setup is ready for owner review.

## Next step

Owner reviews and commits the setup. Then `docs/backlog.md` R-03, the physical-device pass,
is the remaining release-readiness item.

## Blocked or waiting

- `review-log.md` R1-05: session screen, bells, haptics and TTS still need a face-up device
  check. Same phone session as R-03.
- Owner has not yet confirmed the "jab" pronunciation after the forced en-US voice fix.
  Same phone session.
- Resume device work only when the owner says the phone is reconnected.
