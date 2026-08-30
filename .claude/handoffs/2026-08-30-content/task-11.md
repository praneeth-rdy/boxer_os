# Task 11 - Credit string cleanup

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-09
- **Worker:** developer (Opus)
- **Tests:** no (existing tests cover credits being non-empty)

## Goal
Two Commons transcription artifacts appear in credits shown to the user.

## Files
- `lib/data/legends.dart` - modify.

## Spec
Replace the author string `'AnonymousUnknown author'` with `'Unknown'`, and any author
containing `'Unknown authorUnknown author'` with `'Unknown'`. Nothing else changes. Run
`flutter test test/data/legends_test.dart test/pages/about_page_test.dart` and `flutter analyze`.
