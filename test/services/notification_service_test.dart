import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const plugin = MethodChannel('dexterous.com/flutter/local_notifications');
  late List<MethodCall> calls;

  /// Answers every method with [reply], or throws when [reply] is null.
  void answerWith(Object? Function(MethodCall call)? reply) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(plugin, (call) async {
          calls.add(call);
          if (reply == null) {
            throw PlatformException(code: 'unavailable');
          }
          return reply(call);
        });
  }

  /// Initialises the service against a channel that answers every call.
  Future<NotificationService> readyService({DateTime Function()? clock}) async {
    final service = NotificationService(clock: clock);
    answerWith((call) => true);
    final ready = await service.init();
    expect(ready, isTrue, reason: 'init() must succeed for this test');
    calls.clear();
    return service;
  }

  /// The scheduled instant the plugin channel was handed.
  DateTime scheduledInstant() {
    final call = calls.singleWhere((call) => call.method == 'zonedSchedule');
    final arguments = call.arguments as Map<dynamic, dynamic>;
    return DateTime.parse(arguments['scheduledDateTimeISO8601'] as String);
  }

  setUp(() {
    calls = [];
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(plugin, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('NotificationService.init', () {
    test('returns true and becomes ready on a successful call', () async {
      final service = NotificationService();
      answerWith((call) => true);

      final result = await service.init();

      expect(result, isTrue);
      expect(service.isReady, isTrue);
      expect(calls.map((call) => call.method), contains('initialize'));
    });

    test('returns false, not an exception, when the channel throws', () async {
      final service = NotificationService();
      answerWith(null);

      final result = await service.init();

      expect(result, isFalse);
      expect(service.isReady, isFalse);
    });
  });

  group('NotificationService.requestPermission', () {
    test('returns true when the platform grants the request', () async {
      answerWith((call) {
        if (call.method == 'requestNotificationsPermission') {
          return true;
        }
        return null;
      });

      final result = await NotificationService().requestPermission();

      expect(result, isTrue);
    });

    test('returns false, not an exception, when the request throws and '
        'notifications are not enabled either', () async {
      answerWith((call) {
        if (call.method == 'areNotificationsEnabled') {
          return false;
        }
        throw PlatformException(code: 'unavailable');
      });

      final result = await NotificationService().requestPermission();

      expect(result, isFalse);
    });
  });

  group('NotificationService.scheduleDaily', () {
    test('returns false without touching the channel when not ready', () async {
      final service = NotificationService();
      answerWith((call) => true);

      final result = await service.scheduleDaily(
        id: 1,
        hour: 9,
        minute: 0,
        title: 'title',
        body: 'body',
      );

      expect(result, isFalse);
      expect(calls, isEmpty);
    });

    test('schedules today when the target time is still ahead', () async {
      final service = await readyService(
        clock: () => DateTime.utc(2026, 10, 18, 12, 0),
      );
      answerWith((call) => true);

      final result = await service.scheduleDaily(
        id: 7,
        hour: 15,
        minute: 30,
        title: 'title',
        body: 'body',
      );

      expect(result, isTrue);
      final scheduled = scheduledInstant();
      expect(scheduled.year, 2026);
      expect(scheduled.month, 10);
      expect(scheduled.day, 18);
      expect(scheduled.hour, 15);
      expect(scheduled.minute, 30);
    });

    test(
      'schedules tomorrow when the target time has already passed today',
      () async {
        final service = await readyService(
          clock: () => DateTime.utc(2026, 10, 18, 12, 0),
        );
        answerWith((call) => true);

        final result = await service.scheduleDaily(
          id: 7,
          hour: 9,
          minute: 0,
          title: 'title',
          body: 'body',
        );

        expect(result, isTrue);
        final scheduled = scheduledInstant();
        expect(scheduled.year, 2026);
        expect(scheduled.month, 10);
        expect(scheduled.day, 19);
        expect(scheduled.hour, 9);
        expect(scheduled.minute, 0);
      },
    );

    test(
      'schedules tomorrow when the target time is the current minute',
      () async {
        final service = await readyService(
          clock: () => DateTime.utc(2026, 10, 18, 12, 0),
        );
        answerWith((call) => true);

        final result = await service.scheduleDaily(
          id: 7,
          hour: 12,
          minute: 0,
          title: 'title',
          body: 'body',
        );

        expect(result, isTrue);
        final scheduled = scheduledInstant();
        expect(scheduled.year, 2026);
        expect(scheduled.month, 10);
        expect(scheduled.day, 19);
        expect(scheduled.hour, 12);
        expect(scheduled.minute, 0);
      },
    );

    test('returns false, not an exception, when the channel throws', () async {
      final service = await readyService();
      answerWith(null);

      final result = await service.scheduleDaily(
        id: 7,
        hour: 9,
        minute: 0,
        title: 'title',
        body: 'body',
      );

      expect(result, isFalse);
    });
  });

  group('NotificationService.scheduleOnce', () {
    test('returns false without touching the channel when not ready', () async {
      final service = NotificationService();
      answerWith((call) => true);

      final result = await service.scheduleOnce(
        id: 2,
        at: DateTime(2030),
        title: 'title',
        body: 'body',
      );

      expect(result, isFalse);
      expect(calls, isEmpty);
    });

    test(
      'returns false without touching the channel for a past time',
      () async {
        final service = await readyService();
        answerWith((call) => true);

        final result = await service.scheduleOnce(
          id: 2,
          at: DateTime(2000),
          title: 'title',
          body: 'body',
        );

        expect(result, isFalse);
        expect(calls, isEmpty);
      },
    );

    test('returns true and forwards the call on success', () async {
      final service = await readyService();
      answerWith((call) => true);

      final result = await service.scheduleOnce(
        id: 2,
        at: DateTime(2030),
        title: 'title',
        body: 'body',
      );

      expect(result, isTrue);
      expect(calls.map((call) => call.method), contains('zonedSchedule'));
    });

    test('returns false, not an exception, when the channel throws', () async {
      final service = await readyService();
      answerWith(null);

      final result = await service.scheduleOnce(
        id: 2,
        at: DateTime(2030),
        title: 'title',
        body: 'body',
      );

      expect(result, isFalse);
    });
  });

  group('NotificationService.cancel', () {
    test('forwards the id and returns true on success', () async {
      answerWith((call) => null);

      final result = await NotificationService().cancel(5);

      expect(result, isTrue);
      final call = calls.single;
      expect(call.method, 'cancel');
      final arguments = call.arguments as Map<dynamic, dynamic>;
      expect(arguments['id'], 5);
    });

    test('returns false, not an exception, when the channel throws', () async {
      answerWith(null);

      final result = await NotificationService().cancel(5);

      expect(result, isFalse);
    });
  });

  group('NotificationService.cancelAll', () {
    test('returns true on success', () async {
      answerWith((call) => null);

      final result = await NotificationService().cancelAll();

      expect(result, isTrue);
      expect(calls.single.method, 'cancelAll');
    });

    test('returns false, not an exception, when the channel throws', () async {
      answerWith(null);

      final result = await NotificationService().cancelAll();

      expect(result, isFalse);
    });
  });
}
