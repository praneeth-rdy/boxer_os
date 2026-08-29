# Task 10 - Journal entry point as a card row

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-09
- **Worker:** developer (Opus)
- **Tests:** yes (developer adjusts `test/pages/progress_page_test.dart`)

## Goal
Owner feedback: the outlined "Journal" pill on Progress looks old-school and outside the
design system. Replace it with the card row the Skills hub already uses.

## Files
- `lib/pages/progress_page.dart` - modify - the Journal control only.
- `lib/widgets/pill_button.dart` - modify - remove `trailingIcon` if nothing else uses it
  (grep first; keep it if another call site exists).
- `test/pages/progress_page_test.dart` - modify.

## Spec
Under the `SectionHeader`, replace the `PillButton('Journal', ...)` with
`SkillCard(title: 'Journal', description: <caption>, icon: Icons.menu_book_rounded, onTap: push JournalPage)`
where the caption is "{n} sessions logged" ("1 session logged", "Nothing logged yet" for
zero), counting `history.sessions` with `roundsCompleted > 0`. Keep the `spaceMd` gap below
it. Nothing else on the page changes. If `SkillCard` needs a smaller min height to sit well
here, add an optional `compact` flag (min 72 dp) rather than a new widget.

## Acceptance criteria
- [ ] Progress shows the Journal card with the count caption; tapping opens `JournalPage`.
- [ ] No outlined pill remains on Progress; `trailingIcon` removed if unused.
- [ ] `flutter analyze` 0 issues; suite green.
