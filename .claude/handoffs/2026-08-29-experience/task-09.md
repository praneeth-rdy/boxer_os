# Task 09 - Permission hardening and stat labels

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-08, run 6 complete
- **Worker:** developer (Opus)
- **Tests:** yes (developer adjusts the existing tests)

## Goal
Three small findings from the device review: R5-04 root cause (the reminder switch stayed
off after "Allow"), R5-06 (streak nudge bypasses the permission flow), R5-05 (Progress
tile labels wrap to three lines).

## Files
- `lib/services/notification_service.dart` - modify - `requestPermission` re-checks.
- `lib/pages/settings_page.dart` - modify - streak nudge shares the flow.
- `lib/pages/progress_page.dart` - modify - labels only.
- `test/services/reminder_scheduler_test.dart`, `test/pages/settings_page_test.dart`,
  `test/pages/progress_page_test.dart` - modify as needed.

## Spec
1. `NotificationService.requestPermission()`: after `requestNotificationsPermission()` (whether
   it returns false, null, or throws), call `areNotificationsEnabled()` on the Android
   implementation and return that value when it is non-null; only when both are unavailable
   return false. Verify both method names in the plugin source in `~/.pub-cache`. Keep the
   catch (one-line comment).
2. Settings: the streak-nudge switch uses the same `_toggle` path as the daily reminder
   (request permission, apply on grant, SnackBar on refusal). Extract the shared piece so the
   two switches do not duplicate it.
3. Progress: tile labels become "WEEK ROUNDS", "WEEK MINUTES", "DAY STREAK".

## Acceptance criteria
- [ ] Test: a fake plugin whose request throws but whose `areNotificationsEnabled` is true
      yields `requestPermission() == true` (mock the plugin method channel, or inject the
      Android implementation if the service allows it; choose the simpler).
- [ ] Streak-nudge switch: granted -> on with one tap; denied -> off plus SnackBar.
- [ ] Progress labels updated and the existing progress tests pass.
- [ ] `flutter analyze` 0 issues; suite green.
