import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/utils/training_stats.dart';

SessionRecord _record({
  required DateTime startedAt,
  int roundsCompleted = 3,
  int durationSeconds = 180,
  TrainingType type = TrainingType.shadowBoxing,
}) => SessionRecord(
  id: startedAt.millisecondsSinceEpoch.toString(),
  workoutId: 'w',
  workoutName: 'Workout',
  type: type,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: startedAt,
  durationSeconds: durationSeconds,
  roundsCompleted: roundsCompleted,
  roundsPlanned: 3,
  completed: true,
);

void main() {
  // Saturday, so startOfWeek(now) is Monday 2026-08-24.
  final now = DateTime(2026, 8, 29, 18);

  group('TrainingStats.fromSessions streaks', () {
    test('sessions today, yesterday and 3 days ago give a streak of 2', () {
      final stats = TrainingStats.fromSessions([
        _record(startedAt: DateTime(2026, 8, 29, 9)),
        _record(startedAt: DateTime(2026, 8, 28, 9)),
        _record(startedAt: DateTime(2026, 8, 26, 9)),
      ], now: now);

      expect(stats.streakDays, 2);
    });

    test('sessions yesterday and the day before, none today, still give 2', () {
      final stats = TrainingStats.fromSessions([
        _record(startedAt: DateTime(2026, 8, 28, 9)),
        _record(startedAt: DateTime(2026, 8, 27, 9)),
      ], now: now);

      expect(stats.streakDays, 2);
    });

    test('no session today or yesterday gives a streak of 0', () {
      final stats = TrainingStats.fromSessions([
        _record(startedAt: DateTime(2026, 8, 26, 9)),
      ], now: now);

      expect(stats.streakDays, 0);
    });

    test(
      'a session with no completed round does not count toward the streak',
      () {
        final stats = TrainingStats.fromSessions([
          _record(startedAt: DateTime(2026, 8, 29, 9), roundsCompleted: 0),
        ], now: now);

        expect(stats.streakDays, 0);
      },
    );
  });

  group('TrainingStats.fromSessions week totals', () {
    test('weekRounds and weekMinutes exclude sessions from last week', () {
      final stats = TrainingStats.fromSessions([
        _record(
          startedAt: DateTime(2026, 8, 25, 9),
          roundsCompleted: 4,
          durationSeconds: 240,
        ),
        _record(
          startedAt: DateTime(2026, 8, 20, 9),
          roundsCompleted: 5,
          durationSeconds: 300,
        ),
      ], now: now);

      expect(stats.weekRounds, 4);
      expect(stats.weekMinutes, 4);
      expect(stats.totalRounds, 9);
    });

    test('weekRoundsByType only holds types trained this week', () {
      final stats = TrainingStats.fromSessions([
        _record(
          startedAt: DateTime(2026, 8, 25, 9),
          type: TrainingType.sparring,
        ),
        _record(
          startedAt: DateTime(2026, 8, 20, 9),
          type: TrainingType.footwork,
        ),
      ], now: now);

      expect(stats.weekRoundsByType.containsKey(TrainingType.sparring), isTrue);
      expect(
        stats.weekRoundsByType.containsKey(TrainingType.footwork),
        isFalse,
      );
    });
  });

  group('TrainingStats.fromSessions minutesByDay', () {
    test('has 7 entries with today last', () {
      final stats = TrainingStats.fromSessions([
        _record(startedAt: DateTime(2026, 8, 29, 9), durationSeconds: 300),
        _record(startedAt: DateTime(2026, 8, 23, 9), durationSeconds: 600),
      ], now: now);

      expect(stats.minutesByDay, hasLength(7));
      expect(stats.minutesByDay.last, 5);
    });
  });

  group('TrainingStats.fromSessions lastTrainedByType', () {
    test('keeps the most recent session per type across all history', () {
      final stats = TrainingStats.fromSessions([
        _record(
          startedAt: DateTime(2026, 8, 1, 9),
          type: TrainingType.footwork,
        ),
        _record(
          startedAt: DateTime(2026, 8, 20, 9),
          type: TrainingType.footwork,
        ),
      ], now: now);

      expect(
        stats.lastTrainedByType[TrainingType.footwork],
        DateTime(2026, 8, 20, 9),
      );
    });
  });
}
