# Task 04 - injectable clock for NotificationService, deterministic scheduling tests

- **Run:** `.claude/handoffs/2026-10-18-test-coverage/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (developer)

## Goal
The two `scheduleDaily` tests written in task-01 stop depending on the wall clock. Today they
probe with 23:59 and 00:00 and carry a flake window at the minute boundary, because
`NotificationService` reads `tz.TZDateTime.now(tz.local)` directly and offers no seam.
After this task the service takes an optional clock, the way the two providers already do, and
the tests pin "now" to a fixed instant.

## Context the worker needs
- The repo's existing clock seam, which this must match exactly in shape and naming:
  `lib/providers/session_provider.dart:15-18` (`SessionProvider({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;` and `final DateTime Function() _clock;`)
  and `lib/providers/reaction_provider.dart:21-22, 44`.
- `.claude/CLAUDE.md`, **Tests**: mock the clock at the boundary. This task adds the boundary.
- `lib/services/notification_service.dart`: the two call sites are line 118
  (`if (!scheduled.isAfter(tz.TZDateTime.now(tz.local)))` inside `scheduleOnce`) and line 169
  (`final now = tz.TZDateTime.now(tz.local);` inside `_nextOccurrence`).
- `test/services/notification_service_test.dart`, written in task-01: the two tests at lines
  119-155 and 157-195 are the ones to make deterministic. The rest of the file stays as is.
- `memory/notes/wakelock-plus-channel.md` does not bear on this task.

## Files
- `lib/services/notification_service.dart` - modify - add the clock seam, use it at both call sites
- `test/services/notification_service_test.dart` - modify - pin the clock in the two scheduling tests
- `docs/architecture.md` - modify only if the module map row for `notification_service.dart` describes its constructor; otherwise leave it
- (only these; anything else is out of scope)

## Spec

In `NotificationService`:
- Add `NotificationService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;`
  and `final DateTime Function() _clock;`. Same names as the providers, no new type.
- Replace both `tz.TZDateTime.now(tz.local)` reads with
  `tz.TZDateTime.from(_clock(), tz.local)`. `tz.TZDateTime.from(DateTime, Location)` exists in
  `package:timezone`; verify it in the installed package source before relying on it, and if the
  signature differs use what is there.
- No other behaviour change. Default construction (`NotificationService()`) behaves exactly as
  before. Every existing caller that constructs the service without arguments keeps compiling.

In the test file:
- For the two scheduling tests, construct the service with a fixed clock, for example
  `NotificationService(clock: () => DateTime.utc(2026, 10, 18, 12, 0))`, keep the
  service's existing UTC fallback for `tz.local` as task-01 set it up, and assert exact values:
  - a target of 15:30 with the clock at 12:00 schedules 2026-10-18 15:30;
  - a target of 09:00 with the clock at 12:00 schedules 2026-10-19 09:00.
  Assert year, month, day, hour and minute on the scheduled `TZDateTime` captured from the
  mocked channel, as the task-01 tests already capture it.
- Add one more: a target equal to the clock's own minute (12:00 with the clock at 12:00)
  schedules tomorrow, not today. Read `_nextOccurrence`'s comparison to confirm that is what the
  code does; if the code schedules today in that case, assert that instead and say so in NOTES.
- Remove the 23:59 / 00:00 probes and the comment explaining the flake window.

## Out of scope
- Changing `scheduleOnce` semantics, channel ids, or the `init()` timezone fallback.
- Touching `wake_lock_service_test.dart`, `app_motion_test.dart`, or any other test.
- Adding a clock to any other service.

## Acceptance criteria
- [ ] `NotificationService({DateTime Function()? clock})` exists with the same shape as the providers' seam.
- [ ] `grep -n "TZDateTime.now" lib/services/notification_service.dart` returns nothing.
- [ ] The two scheduling tests use a fixed clock and assert exact year/month/day/hour/minute; the boundary test exists.
- [ ] No `DateTime.now()` or `TZDateTime.now` remains in `test/services/notification_service_test.dart`.
- [ ] `flutter test test/services/notification_service_test.dart` passes.
- [ ] `flutter analyze` introduces no new issues.

## Verification
`flutter test test/services/notification_service_test.dart`, then `flutter analyze`, then `dart format` on both touched files.
