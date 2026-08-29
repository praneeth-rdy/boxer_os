# Task 11 - "Journal" becomes "History"

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-10
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates the affected tests)

## Goal
Owner feedback: "Journal" is jargon. The feature is the list of logged sessions, so it is
called "Sessions" everywhere a boxer reads it, and the code follows.

## Files
- `lib/pages/journal_page.dart` -> rename to `lib/pages/sessions_page.dart`, class
  `JournalPage` -> `SessionsPage`, `_EmptyJournal` -> `_EmptySessions`.
- `lib/pages/progress_page.dart` - modify - card title "Sessions", caption "{n} logged" /
  "1 logged" / "Nothing logged yet", helper and method names follow (`_sessionsCaption`,
  `_openSessions`), import path.
- `lib/pages/session_detail_page.dart` - modify - delete dialog copy: "It leaves your sessions
  and your totals." Doc comment: "with the notes and a delete action".
- `lib/pages/session_complete_page.dart` - modify - doc comment and `_journal` -> `_notes`
  (private method name only; the sheet itself is unchanged).
- `lib/pages/sessions_page.dart` - header `SectionHeader(title: 'Sessions', eyebrow: 'EVERY ROUND
  YOU LOGGED')`; empty state action label stays "Go to Train"; empty-state copy: title "Your
  first session lands here.", body "Every finished session is saved with your rating and notes.
  Sparring days get opponent notes too."
- `lib/widgets/journal_field.dart` - leave the file and class name (it is a form field, not the
  feature); no user-facing string in it.
- Tests: `test/pages/journal_page_test.dart` -> `test/pages/sessions_page_test.dart`,
  `test/pages/progress_page_test.dart`, `test/pages/session_detail_page_test.dart`, any other
  test referencing `JournalPage` or the strings above.
- `docs/architecture.md` - modify - rows and the Navigation paragraph.

## Acceptance criteria
- [ ] `grep -rn "Journal" lib test` returns only `JournalField` / `journal_field` matches.
- [ ] Progress card reads "Sessions"; the page header reads "Sessions"; empty state copy as above.
- [ ] `flutter analyze` 0 issues; suite green.
