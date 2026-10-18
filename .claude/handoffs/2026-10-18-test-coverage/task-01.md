# Task 01 - tests for the notification, wake lock and motion layer

- **Run:** `.claude/handoffs/2026-10-18-test-coverage/`
- **Depends on:** none
- **Worker:** assistant (Sonnet)
- **Tests:** yes (assistant)

## Goal
The three untested pieces of platform-facing code gain tests that pin their real contract: that
they contain platform failures instead of throwing, and that the scheduling and reduce-motion
logic computes what it claims to.

## Context the worker needs
- `.claude/CLAUDE.md`, **Error handling**: services return null/false on failure and never throw
  across the UI boundary. That contract is the main thing these tests exist to protect.
- `.claude/CLAUDE.md`, **Tests**: mock prefs with `SharedPreferences.setMockInitialValues`,
  platform channels with `TestDefaultBinaryMessengerBinding`.
- `test/services/haptics_service_test.dart` and `test/services/reminder_scheduler_test.dart`
  already mock channels in this repo's style. Follow them.
- No `memory/notes/` file bears on this task.

## Files
- `test/services/notification_service_test.dart` - create
- `test/services/wake_lock_service_test.dart` - create
- `test/theme/app_motion_test.dart` - create
- (only these three; `lib/` is out of scope)

## Spec

**`NotificationService`** (`lib/services/notification_service.dart`). Public surface:
`init()`, `requestPermission()`, `scheduleDaily({...})`, `scheduleOnce({...})`, `cancel(int id)`,
`cancelAll()`, all returning `Future<bool>`. Read the file for the exact named parameters before
writing anything; do not assume them.

Do not guess the plugin's MethodChannel name. Find it in the installed
`flutter_local_notifications` source (under the pub cache) or in the plugin's Dart source that
`pubspec.lock` pins, and use the name you found.

Cover:
- every public method returns `false` (and does not throw) when the mocked channel throws a
  `PlatformException`.
- every public method returns `true` on a successful mocked call.
- `scheduleDaily` picks the next occurrence correctly: given a fixed local time, a target time
  still ahead today schedules today, a target time already past schedules tomorrow. The helper
  is private, so assert through the arguments the service passes to the channel. Initialise
  `timezone` in the test the way the service expects (`tz.initializeTimeZones()` and a fixed
  local location) so the result does not depend on the machine's zone.
- `cancel` and `cancelAll` forward the id / no id to the channel.

**`WakeLockService`** (`lib/services/wake_lock_service.dart`): `enable()` and `disable()` return
`true` on success and `false` when the platform throws. Mock the `wakelock_plus` channel; take
its name from the installed plugin, not from memory.

**`AppMotion`** (`lib/theme/app_motion.dart`): `reduced(context)` is true when
`MediaQuery.disableAnimations` is true, false otherwise; `of(context, duration)` returns
`Duration.zero` when motion is reduced and the duration unchanged otherwise. Pump a widget
wrapped in `MediaQuery` with `disableAnimations` set each way.

## Out of scope
- Any edit under `lib/`. If a test needs one, return `BLOCKED` naming the obstacle.
- Testing the `flutter_local_notifications` plugin itself. Mock the boundary, assert our code.
- `services/reminder_scheduler.dart`, already covered.

## Acceptance criteria
- [ ] The three files exist under `test/` mirroring their `lib/` paths.
- [ ] Each public method of both services has a success case and a platform-failure case.
- [ ] A `scheduleDaily` test proves the today-vs-tomorrow branch with a fixed clock and zone.
- [ ] `AppMotion` is covered in both the reduced and the normal state.
- [ ] `flutter test` passes, and the run does not depend on the machine's timezone or today's date.
- [ ] `flutter analyze` introduces no new issues.

## Verification
`flutter test test/services/notification_service_test.dart test/services/wake_lock_service_test.dart test/theme/app_motion_test.dart`, then `flutter analyze`, then `dart format` on the files you created.
