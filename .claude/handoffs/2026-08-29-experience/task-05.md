# Task 05 - Reminders

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-04
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Local reminder notifications scheduled from inside the app: a daily training reminder at a
time the boxer picks (default 18:00) and a streak nudge at 20:00 only on days without a
session. No server, no push service.

## Context the worker needs
- Packages (pub.dev, verified 2026-08-29): `flutter_local_notifications: ^22.3.0` (Flutter
  >= 3.38.1), `timezone: ^0.11.1`, `flutter_timezone: ^5.1.0`. Read the plugin README in
  `~/.pub-cache` for the Android setup (receivers, permissions, `zonedSchedule` signature,
  `AndroidScheduleMode`). Use inexact scheduling so no exact-alarm permission is needed.
- `SettingsProvider`, `HistoryProvider`, `TrainingStats` (streak), `quoteOfTheDay`
  (task-04), `main.dart` wiring style of `CueController`.
- Android 13+ needs the `POST_NOTIFICATIONS` runtime permission; the test phone is Android 16.

## Files
- `pubspec.yaml` - modify - the three dependencies.
- `android/app/src/main/AndroidManifest.xml` - modify - permissions and receivers.
- `lib/services/notification_service.dart` - create.
- `lib/services/reminder_scheduler.dart` - create.
- `lib/providers/settings_provider.dart` - modify - reminder keys.
- `lib/pages/settings_page.dart` - modify - REMINDERS section.
- `lib/main.dart` - modify - init and wire.
- `docs/architecture.md` - modify - rows, keys, native bridge (permissions, receivers).

## Spec

### Settings keys
`reminderEnabledKey = 'reminder_enabled'` (bool, false), `reminderHourKey = 'reminder_hour'`
(int, 18), `reminderMinuteKey = 'reminder_minute'` (int, 0),
`streakNudgeEnabledKey = 'streak_nudge_enabled'` (bool, false). Getters and setters
(`setReminderEnabled`, `setReminderTime(int hour, int minute)`, `setStreakNudgeEnabled`).

### `NotificationService`
Plain class over `FlutterLocalNotificationsPlugin`:
- `Future<bool> init()`: `tz.initializeTimeZones()`, set `tz.local` from
  `FlutterTimezone.getLocalTimezone()` (fall back to UTC on failure), initialise the plugin
  with `AndroidInitializationSettings('@mipmap/ic_launcher')`, create one channel
  `reminders` ("Training reminders", importance default). Idempotent; false on throw.
- `Future<bool> requestPermission()`: Android `requestNotificationsPermission()`; returns the
  result, false on throw or null.
- `Future<bool> scheduleDaily({required int id, required int hour, required int minute, required String title, required String body})`:
  `zonedSchedule` at the next occurrence, `matchDateTimeComponents: DateTimeComponents.time`,
  `androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle`.
- `Future<bool> scheduleOnce({required int id, required DateTime at, ...})`: same without
  `matchDateTimeComponents`; ignores `at` in the past (returns false).
- `Future<bool> cancel(int id)`, `Future<bool> cancelAll()`.
Ids: `dailyReminderId = 1`, `streakNudgeId = 2` as `static const`.

### `ReminderScheduler`
```dart
class ReminderScheduler {
  ReminderScheduler({required SettingsProvider settings, required HistoryProvider history,
    required NotificationService notifications, DateTime Function()? clock});
  Future<void> sync();   // idempotent; called on construction, and whenever settings or history notify
  void dispose();
}
```
`sync()`:
- Daily: if `reminderEnabled`, `scheduleDaily(id 1, hour, minute, title: 'Time to train',
  body: quoteOfTheDay(now).text)`; else `cancel(1)`.
- Streak nudge: if `streakNudgeEnabled`: compute `stats = TrainingStats.fromSessions(history.sessions, now)`.
  If a counted session exists today -> schedule once for tomorrow 20:00 (body
  "Your {streakDays}-day streak is on the line tonight." or, when streak is 0, "A session
  today starts a streak."); else if now is before 20:00 today -> schedule once for today 20:00;
  else tomorrow 20:00. Disabled -> `cancel(2)`.
Debounce: coalesce listener bursts with a 300 ms `Timer` (cancelled in `dispose`). Never
awaits inside a listener callback; errors from the service are ignored with a one-line comment
(reminders are best effort).

### Settings page, REMINDERS section (before DATA)
- `SwitchListTile` "Daily reminder" (subtitle "A nudge at the time you pick"): turning on calls
  `notifications.requestPermission()` first (via a `Provider<NotificationService>.value` added
  in `main`, like `VoiceService`); if denied, show a `SnackBar` "Notifications are off for
  Boxer OS in Android settings." and leave the switch off.
- A row "Time" with the current time in `displaySmall` and a 48 dp edit icon opening
  `showTimePicker` (24 h or locale default), enabled only when the daily reminder is on.
- `SwitchListTile` "Streak nudge" (subtitle "8 pm, only on days you haven't trained").

### Manifest
Per the plugin README for v22: `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`,
`RECEIVE_BOOT_COMPLETED`, `VIBRATE` (if the README lists it), and the two receivers
(`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` with the boot intent
filter). Do not add `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM`.

### `main.dart`
`final notifications = NotificationService(); await notifications.init();` then
`ReminderScheduler(...)` held like `cues`. Provide `Provider<NotificationService>.value`.

## Out of scope
- Notification tap handling beyond opening the app. Rich notifications, actions, sounds.
- Reminder analytics.

## Acceptance criteria
- [ ] With a fake `NotificationService` (subclass recording calls) and a fake clock:
      enabling the daily reminder schedules id 1 at 18:00 with the quote; disabling cancels it;
      the streak nudge schedules id 2 for today 20:00 when no session today and now is 09:00,
      for tomorrow 20:00 when a session was logged today, and cancels when disabled.
- [ ] Settings shows the section; the time row updates after picking; the switch stays off
      when permission is denied (fake service returning false).
- [ ] `flutter build apk --debug` succeeds with the manifest changes; the app requests
      notification permission when the switch is turned on (device check by the assistant).
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/services/reminder_scheduler_test.dart`, extend
  `test/pages/settings_page_test.dart`, `test/providers/settings_provider_test.dart`.
