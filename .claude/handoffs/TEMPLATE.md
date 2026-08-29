# Task NN - <short title>

- **Run:** `.claude/handoffs/<YYYY-MM-DD>-<slug>/`
- **Depends on:** none | task-NN
- **Worker:** developer (Opus) | assistant (Sonnet)
- **Tests:** yes (assistant) | yes (developer) | no

## Goal
One paragraph. What the user gets when this is done.

## Context the worker needs
- Pointers to the relevant `CLAUDE.md` sections and files, and *why* they matter. No code dumps.

## Files
- `lib/...` - create | modify - what changes in one line
- (only these files; anything else is out of scope)

## Spec
Precise. Signatures, prefs keys, UI behaviour, edge cases. If there is a decision to make,
make it here - the worker must not choose.

## Out of scope
Tempting adjacent changes the worker must NOT make.

## Acceptance criteria
- [ ] Checkable statements, each verifiable by a test or by reading the diff.
- [ ] `flutter analyze` introduces no new issues.

## Verification
Commands to run and/or tests to write (this is what the assistant works from when Tests: yes).
