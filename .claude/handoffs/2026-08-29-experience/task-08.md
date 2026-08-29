# Task 08 - Reminder switch turns on once permission is granted

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-05
- **Worker:** developer (Opus)
- **Tests:** yes (developer adjusts `test/pages/settings_page_test.dart`)

## Goal
Device finding R5-04: tapping the "Daily reminder" switch shows the Android permission dialog;
after "Allow" the switch stays off and needs a second tap. It should end up on.

## Context the worker needs
- `lib/pages/settings_page.dart` (REMINDERS section), `lib/services/notification_service.dart`
  (`requestPermission`), `test/pages/settings_page_test.dart`.
- Another workflow is editing reaction files right now; touch only the two files below.

## Files
- `lib/pages/settings_page.dart` - modify.
- `test/pages/settings_page_test.dart` - modify.

## Spec
The switch handler awaits `requestPermission()` and then, when it returns true, calls
`setReminderEnabled(true)`. Verify the actual flow: if the `await` result is discarded, or the
setter runs before the dialog resolves, or the widget rebuilds from a stale value, fix it so
that granting leads to `reminderEnabled == true` with no second tap; a refusal keeps it off and
shows the existing SnackBar. Guard the `BuildContext` after the await (`if (!context.mounted)
return;`). The same for the streak-nudge switch if it shares the flow.

## Acceptance criteria
- [ ] Widget test with a fake `NotificationService` whose `requestPermission()` completes true
      after a delay: tapping the switch once leaves it on; with false, it stays off and the
      SnackBar appears.
- [ ] `flutter analyze` 0 issues; suite green.
