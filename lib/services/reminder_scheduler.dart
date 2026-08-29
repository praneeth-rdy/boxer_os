import 'dart:async';

import '../data/quotes.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/date_helpers.dart';
import '../utils/training_stats.dart';
import 'notification_service.dart';

/// Keeps the scheduled reminders in step with the settings and today's training.
class ReminderScheduler {
  ReminderScheduler({
    required SettingsProvider settings,
    required HistoryProvider history,
    required NotificationService notifications,
    DateTime Function()? clock,
  }) : _settings = settings,
       _history = history,
       _notifications = notifications,
       _clock = clock ?? DateTime.now {
    _settings.addListener(_onChanged);
    _history.addListener(_onChanged);
    unawaited(sync());
  }

  static const Duration _settleDelay = Duration(milliseconds: 300);
  static const int _nudgeHour = 20;
  static const String _dailyTitle = 'Time to train';
  static const String _nudgeTitle = 'Keep the streak';

  final SettingsProvider _settings;
  final HistoryProvider _history;
  final NotificationService _notifications;
  final DateTime Function() _clock;

  Timer? _settle;

  void dispose() {
    _settle?.cancel();
    _settings.removeListener(_onChanged);
    _history.removeListener(_onChanged);
  }

  /// Rewrites both reminders from the current settings and history.
  Future<void> sync() async {
    final now = _clock();
    await _syncDailyReminder(now);
    await _syncStreakNudge(now);
  }

  void _onChanged() {
    _settle?.cancel();
    _settle = Timer(_settleDelay, () => unawaited(sync()));
  }

  Future<void> _syncDailyReminder(DateTime now) async {
    if (!_settings.reminderEnabled) {
      // Reminders are best effort, so a refused cancel is not worth reporting.
      await _notifications.cancel(NotificationService.dailyReminderId);
      return;
    }
    await _notifications.scheduleDaily(
      id: NotificationService.dailyReminderId,
      hour: _settings.reminderHour,
      minute: _settings.reminderMinute,
      title: _dailyTitle,
      body: quoteOfTheDay(now).text,
    );
  }

  Future<void> _syncStreakNudge(DateTime now) async {
    if (!_settings.streakNudgeEnabled) {
      await _notifications.cancel(NotificationService.streakNudgeId);
      return;
    }
    final stats = TrainingStats.fromSessions(_history.sessions, now: now);
    await _notifications.scheduleOnce(
      id: NotificationService.streakNudgeId,
      at: _nudgeTime(now, trainedToday: _hasSessionToday(now)),
      title: _nudgeTitle,
      body: _nudgeBody(stats.streakDays),
    );
  }

  /// Tonight at 8 while the day is still open, otherwise tomorrow at 8.
  DateTime _nudgeTime(DateTime now, {required bool trainedToday}) {
    final tonight = DateTime(now.year, now.month, now.day, _nudgeHour);
    if (!trainedToday && now.isBefore(tonight)) {
      return tonight;
    }
    return DateTime(now.year, now.month, now.day + 1, _nudgeHour);
  }

  String _nudgeBody(int streakDays) => streakDays == 0
      ? 'A session today starts a streak.'
      : 'Your $streakDays-day streak is on the line tonight.';

  /// Matches [TrainingStats]: a session with no completed round is not training.
  bool _hasSessionToday(DateTime now) => _history.sessions.any(
    (record) => record.roundsCompleted > 0 && isSameDay(record.startedAt, now),
  );
}
