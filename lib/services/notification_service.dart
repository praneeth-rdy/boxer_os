import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the local reminder notifications; every call fails soft.
class NotificationService {
  static const int dailyReminderId = 1;
  static const int streakNudgeId = 2;

  static const String _channelId = 'reminders';
  static const String _channelName = 'Training reminders';
  static const String _channelDescription =
      'Daily training reminders and streak nudges.';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isReady = false;

  /// False until [init] succeeds, so callers can skip scheduling entirely.
  bool get isReady => _isReady;

  Future<bool> init() async {
    if (_isReady) {
      return true;
    }
    try {
      tz_data.initializeTimeZones();
      await _useLocalTimezone();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
            ),
          );
      _isReady = true;
    } catch (failure) {
      // Without notifications the app still trains; reminders just stay off.
      return false;
    }
    return true;
  }

  /// Asks for the Android 13+ notification permission; false when refused.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return false;
    }
    try {
      if (await android.requestNotificationsPermission() ?? false) {
        return true;
      }
    } catch (failure) {
      // A refused or throwing request still leaves the real state readable.
    }
    try {
      return await android.areNotificationsEnabled() ?? false;
    } catch (failure) {
      return false;
    }
  }

  /// Repeats every day at [hour]:[minute], starting at the next occurrence.
  Future<bool> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) {
    if (!_isReady) {
      return Future.value(false);
    }
    return _schedule(
      id: id,
      at: _nextOccurrence(hour, minute),
      title: title,
      body: body,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Fires once at [at]; a time already past is not scheduled.
  Future<bool> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) {
    if (!_isReady) {
      return Future.value(false);
    }
    final scheduled = tz.TZDateTime.from(at, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
      return Future.value(false);
    }
    return _schedule(id: id, at: scheduled, title: title, body: body);
  }

  Future<bool> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
      return true;
    } catch (failure) {
      return false;
    }
  }

  Future<bool> cancelAll() async {
    try {
      await _plugin.cancelAll();
      return true;
    } catch (failure) {
      return false;
    }
  }

  Future<bool> _schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (!_isReady) {
      return false;
    }
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      return true;
    } catch (failure) {
      return false;
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (today.isAfter(now)) {
      return today;
    }
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      hour,
      minute,
    );
  }

  /// UTC is the fallback so a missing platform zone still schedules something.
  Future<void> _useLocalTimezone() async {
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (failure) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
