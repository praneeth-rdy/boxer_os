import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/providers/settings_provider.dart';
import 'package:boxer_os/services/notification_service.dart';
import 'package:boxer_os/services/reminder_scheduler.dart';

/// Records every call instead of touching the platform plugin.
class _FakeNotificationService extends NotificationService {
  final List<Map<String, Object?>> dailyCalls = [];
  final List<Map<String, Object?>> onceCalls = [];
  final List<int> cancelled = [];

  @override
  Future<bool> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    dailyCalls.add({
      'id': id,
      'hour': hour,
      'minute': minute,
      'title': title,
      'body': body,
    });
    return true;
  }

  @override
  Future<bool> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    onceCalls.add({'id': id, 'at': at, 'title': title, 'body': body});
    return true;
  }

  @override
  Future<bool> cancel(int id) async {
    cancelled.add(id);
    return true;
  }
}

SessionRecord _sessionAt(DateTime startedAt) => SessionRecord(
  id: startedAt.toIso8601String(),
  workoutId: 'shadow_foundations',
  workoutName: 'Shadow Foundations',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: startedAt,
  durationSeconds: 180,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
);

/// Builds a scheduler over settings/history already in their final state, so
/// only the constructor's own sync() runs and no debounce timer is armed.
Future<ReminderScheduler> _buildScheduler({
  required SettingsProvider settings,
  required HistoryProvider history,
  required _FakeNotificationService notifications,
  required DateTime now,
}) async {
  final scheduler = ReminderScheduler(
    settings: settings,
    history: history,
    notifications: notifications,
    clock: () => now,
  );
  // Flushes the constructor's unawaited sync() before assertions run.
  await Future<void>.delayed(Duration.zero);
  return scheduler;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationService.requestPermission', () {
    const plugin = MethodChannel('dexterous.com/flutter/local_notifications');

    void answerWith({required Object? Function(String method) reply}) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(plugin, (call) async => reply(call.method));
    }

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(plugin, null);
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'grants when the request throws but notifications are enabled',
      () async {
        answerWith(
          reply: (method) {
            if (method == 'areNotificationsEnabled') {
              return true;
            }
            throw PlatformException(code: 'unavailable');
          },
        );

        expect(await NotificationService().requestPermission(), isTrue);
      },
    );

    test(
      'refuses when the request and the enabled check both say no',
      () async {
        answerWith(reply: (method) => false);

        expect(await NotificationService().requestPermission(), isFalse);
      },
    );
  });

  group('ReminderScheduler.sync daily reminder', () {
    test(
      'enabling schedules id 1 at the settings time with the quote',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setReminderEnabled(true);
        final now = DateTime(2026, 8, 29, 9);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        expect(notifications.dailyCalls, hasLength(1));
        final call = notifications.dailyCalls.single;
        expect(call['id'], NotificationService.dailyReminderId);
        expect(call['hour'], 18);
        expect(call['minute'], 0);
        expect(call['body'], quoteFor(QuoteSurface.reminder, now).text);

        scheduler.dispose();
      },
    );

    test('schedules at the custom time set via setReminderTime', () async {
      final settings = SettingsProvider();
      await settings.load();
      await settings.setReminderTime(7, 30);
      await settings.setReminderEnabled(true);
      final now = DateTime(2026, 8, 29, 9);
      final history = HistoryProvider();
      final notifications = _FakeNotificationService();

      final scheduler = await _buildScheduler(
        settings: settings,
        history: history,
        notifications: notifications,
        now: now,
      );

      final call = notifications.dailyCalls.single;
      expect(call['hour'], 7);
      expect(call['minute'], 30);

      scheduler.dispose();
    });

    test('the reminder off by default never schedules', () async {
      final settings = SettingsProvider();
      await settings.load();
      final now = DateTime(2026, 8, 29, 9);
      final history = HistoryProvider();
      final notifications = _FakeNotificationService();

      final scheduler = await _buildScheduler(
        settings: settings,
        history: history,
        notifications: notifications,
        now: now,
      );

      expect(notifications.dailyCalls, isEmpty);
      expect(
        notifications.cancelled,
        contains(NotificationService.dailyReminderId),
      );

      scheduler.dispose();
    });
  });

  group('ReminderScheduler.sync streak nudge', () {
    test(
      'schedules id 2 for today 20:00 when no session today and now is 09:00',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setStreakNudgeEnabled(true);
        final now = DateTime(2026, 8, 29, 9);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        expect(notifications.onceCalls, hasLength(1));
        final call = notifications.onceCalls.single;
        expect(call['id'], NotificationService.streakNudgeId);
        expect(call['at'], DateTime(2026, 8, 29, 20));
        expect(call['body'], 'A session today starts a streak.');

        scheduler.dispose();
      },
    );

    test(
      'schedules id 2 for tomorrow 20:00 when a session was logged today',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setStreakNudgeEnabled(true);
        final now = DateTime(2026, 8, 29, 9);
        final history = HistoryProvider();
        await history.addSession(_sessionAt(DateTime(2026, 8, 29, 8)));
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        final call = notifications.onceCalls.single;
        expect(call['at'], DateTime(2026, 8, 30, 20));

        scheduler.dispose();
      },
    );

    test(
      'schedules id 2 for tomorrow 20:00 when now is already past 20:00',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setStreakNudgeEnabled(true);
        final now = DateTime(2026, 8, 29, 21);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        final call = notifications.onceCalls.single;
        expect(call['at'], DateTime(2026, 8, 30, 20));

        scheduler.dispose();
      },
    );

    test('the nudge off by default never schedules', () async {
      final settings = SettingsProvider();
      await settings.load();
      final now = DateTime(2026, 8, 29, 9);
      final history = HistoryProvider();
      final notifications = _FakeNotificationService();

      final scheduler = await _buildScheduler(
        settings: settings,
        history: history,
        notifications: notifications,
        now: now,
      );

      expect(notifications.onceCalls, isEmpty);
      expect(
        notifications.cancelled,
        contains(NotificationService.streakNudgeId),
      );

      scheduler.dispose();
    });

    test('body includes the streak length when there is one', () async {
      final settings = SettingsProvider();
      await settings.load();
      await settings.setStreakNudgeEnabled(true);
      final now = DateTime(2026, 8, 29, 9);
      final history = HistoryProvider();
      await history.addSession(_sessionAt(DateTime(2026, 8, 28, 8)));
      final notifications = _FakeNotificationService();

      final scheduler = await _buildScheduler(
        settings: settings,
        history: history,
        notifications: notifications,
        now: now,
      );

      final call = notifications.onceCalls.single;
      expect(call['body'], 'Your 1-day streak is on the line tonight.');

      scheduler.dispose();
    });
  });

  group('ReminderScheduler.sync event reminder', () {
    test(
      "schedules id 3 for today's event at 09:00 when it is still morning",
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setEventRemindersEnabled(true);
        final now = DateTime(2026, 10, 30, 8);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        expect(notifications.onceCalls, hasLength(1));
        final call = notifications.onceCalls.single;
        expect(call['id'], NotificationService.eventReminderId);
        expect(call['at'], DateTime(2026, 10, 30, 9));
        expect(call['title'], 'The Rumble in the Jungle');

        scheduler.dispose();
      },
    );

    test(
      'schedules the next event once 09:00 has already passed today',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setEventRemindersEnabled(true);
        final now = DateTime(2026, 10, 30, 10);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        final call = notifications.onceCalls.single;
        expect(call['title'], 'Foreman, champion at forty-five');
        expect(call['at'], DateTime(2026, 11, 5, 9));

        scheduler.dispose();
      },
    );

    test(
      'wraps into next year when the next event has already passed this year',
      () async {
        final settings = SettingsProvider();
        await settings.load();
        await settings.setEventRemindersEnabled(true);
        final now = DateTime(2026, 12, 27, 9);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = await _buildScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          now: now,
        );

        final call = notifications.onceCalls.single;
        expect(call['title'], 'George Foreman born');
        expect(call['at'], DateTime(2027, 1, 10, 9));

        scheduler.dispose();
      },
    );

    test('the event reminder off by default never schedules', () async {
      final settings = SettingsProvider();
      await settings.load();
      final now = DateTime(2026, 10, 30, 8);
      final history = HistoryProvider();
      final notifications = _FakeNotificationService();

      final scheduler = await _buildScheduler(
        settings: settings,
        history: history,
        notifications: notifications,
        now: now,
      );

      expect(notifications.onceCalls, isEmpty);
      expect(
        notifications.cancelled,
        contains(NotificationService.eventReminderId),
      );

      scheduler.dispose();
    });
  });

  test(
    'a setting change resyncs after the debounce delay, cancelling the reminder when it flips off',
    () {
      fakeAsync((async) {
        final settings = SettingsProvider();
        unawaited(settings.load());
        async.flushMicrotasks();
        unawaited(settings.setReminderEnabled(true));
        async.flushMicrotasks();
        final now = DateTime(2026, 8, 29, 9);
        final history = HistoryProvider();
        final notifications = _FakeNotificationService();

        final scheduler = ReminderScheduler(
          settings: settings,
          history: history,
          notifications: notifications,
          clock: () => now,
        );
        async.flushMicrotasks();
        expect(notifications.dailyCalls, hasLength(1));
        notifications.dailyCalls.clear();
        notifications.cancelled.clear();

        unawaited(settings.setReminderEnabled(false));
        async.flushMicrotasks();
        // The debounce has not elapsed yet, so the sync has not re-run.
        expect(notifications.cancelled, isEmpty);

        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        expect(
          notifications.cancelled,
          contains(NotificationService.dailyReminderId),
        );
        expect(notifications.dailyCalls, isEmpty);

        scheduler.dispose();
      });
    },
  );
}
