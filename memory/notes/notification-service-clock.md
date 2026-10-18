# NotificationService tests: why tz.local is UTC and where the instant lands

For `test/services/notification_service_test.dart`:

- `tz.local` resolves to UTC in tests because only the `dexterous.com/flutter/local_notifications`
  channel is mocked; `FlutterTimezone.getLocalTimezone()` throws `MissingPluginException` and
  `init()` falls back to `tz.UTC`. A fixed UTC clock therefore maps straight to the asserted
  wall-clock values. Mocking the flutter_timezone channel would break that assumption.
- The scheduled instant arrives on the channel as the `scheduledDateTimeISO8601` string argument
  of the `zonedSchedule` call.
- `_nextOccurrence` compares with `today.isAfter(now)`, so a target equal to the current minute
  schedules tomorrow, not today.

The clock seam itself is recorded in `docs/decisions.md` (2026-10-18).
