import '../models/session_record.dart';
import '../models/training_type.dart';
import 'date_helpers.dart';

/// The training numbers Home and Progress show, derived from session history.
class TrainingStats {
  const TrainingStats({
    required this.weekRounds,
    required this.weekMinutes,
    required this.streakDays,
    required this.totalRounds,
    required this.totalMinutes,
    required this.totalSessions,
    required this.weekRoundsByType,
    required this.minutesByDay,
    required this.lastTrainedByType,
  });

  /// Sessions with no completed round do not count as training.
  factory TrainingStats.fromSessions(
    List<SessionRecord> sessions, {
    required DateTime now,
  }) {
    final weekStart = startOfWeek(now);
    final today = startOfDay(now);
    final weekRoundsByType = <TrainingType, int>{};
    final lastTrainedByType = <TrainingType, DateTime>{};
    final minutesByDay = List<int>.filled(_dayWindow, 0);
    final trainedDays = <DateTime>{};
    var weekRounds = 0;
    var weekMinutes = 0;
    var totalRounds = 0;
    var totalMinutes = 0;
    var totalSessions = 0;

    for (final record in sessions) {
      if (record.roundsCompleted <= 0) {
        continue;
      }
      totalSessions++;
      totalRounds += record.roundsCompleted;
      totalMinutes += record.workMinutes;
      trainedDays.add(startOfDay(record.startedAt));
      final lastOfType = lastTrainedByType[record.type];
      if (lastOfType == null || record.startedAt.isAfter(lastOfType)) {
        lastTrainedByType[record.type] = record.startedAt;
      }
      if (!record.startedAt.isBefore(weekStart)) {
        weekRounds += record.roundsCompleted;
        weekMinutes += record.workMinutes;
        weekRoundsByType.update(
          record.type,
          (rounds) => rounds + record.roundsCompleted,
          ifAbsent: () => record.roundsCompleted,
        );
      }
      final index = _dayWindow - 1 - _daysBetween(record.startedAt, now);
      if (index >= 0 && index < _dayWindow) {
        minutesByDay[index] += record.workMinutes;
      }
    }

    return TrainingStats(
      weekRounds: weekRounds,
      weekMinutes: weekMinutes,
      streakDays: _streakDays(trainedDays, today),
      totalRounds: totalRounds,
      totalMinutes: totalMinutes,
      totalSessions: totalSessions,
      weekRoundsByType: weekRoundsByType,
      minutesByDay: minutesByDay,
      lastTrainedByType: lastTrainedByType,
    );
  }

  static const int _dayWindow = 7;

  final int weekRounds;
  final int weekMinutes;

  /// Consecutive days trained, counting back from today (or yesterday).
  final int streakDays;

  final int totalRounds;
  final int totalMinutes;
  final int totalSessions;
  final Map<TrainingType, int> weekRoundsByType;

  /// Seven entries, index 0 six days ago through index 6 today.
  final List<int> minutesByDay;

  final Map<TrainingType, DateTime> lastTrainedByType;

  /// A streak survives the day after the last session, so it starts at yesterday
  /// when today has no session yet.
  static int _streakDays(Set<DateTime> trainedDays, DateTime today) {
    var cursor = trainedDays.contains(today) ? today : _dayBefore(today);
    var days = 0;
    while (trainedDays.contains(cursor)) {
      days++;
      cursor = _dayBefore(cursor);
    }
    return days;
  }

  static DateTime _dayBefore(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);

  /// Calendar days between the two dates, unaffected by daylight saving shifts.
  static int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
