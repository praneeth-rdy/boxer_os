import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/workout_library.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/utils/recommendation.dart';
import 'package:boxer_os/utils/training_stats.dart';

TrainingStats _stats({
  Map<TrainingType, DateTime> lastTrainedByType = const {},
}) => TrainingStats(
  weekRounds: 0,
  weekMinutes: 0,
  streakDays: 0,
  totalRounds: 0,
  totalMinutes: 0,
  totalSessions: 0,
  weekRoundsByType: const {},
  minutesByDay: const [0, 0, 0, 0, 0, 0, 0],
  lastTrainedByType: lastTrainedByType,
);

void main() {
  final now = DateTime(2026, 8, 29, 9);

  test('empty stats and beginner returns shadow_foundations', () {
    final workout = recommendWorkout(_stats(), Difficulty.beginner, now: now);

    expect(workout.id, 'shadow_foundations');
  });

  test('after a shadow session today it returns a heavy-bag workout', () {
    final stats = _stats(lastTrainedByType: {TrainingType.shadowBoxing: now});

    final workout = recommendWorkout(stats, Difficulty.beginner, now: now);

    expect(workout.type, TrainingType.heavyBag);
  });

  test('sparring is never recommended, whatever the history or level', () {
    for (final difficulty in Difficulty.values) {
      final stats = _stats(
        lastTrainedByType: {
          for (final type in TrainingType.values)
            if (type != TrainingType.sparring) type: now,
        },
      );

      final workout = recommendWorkout(stats, difficulty, now: now);

      expect(workout.type, isNot(TrainingType.sparring));
    }
  });

  test('the difficulty preference is honoured when a match exists', () {
    final stats = _stats(
      lastTrainedByType: {
        for (final type in TrainingType.values)
          if (type != TrainingType.heavyBag) type: now,
      },
    );

    final workout = recommendWorkout(stats, Difficulty.advanced, now: now);

    expect(workout.type, TrainingType.heavyBag);
    expect(workout.difficulty, Difficulty.advanced);
    expect(workout.id, 'power_rounds');
  });

  test(
    'a never-trained type is treated as the oldest, ahead of any trained type',
    () {
      final stats = _stats(
        lastTrainedByType: {TrainingType.shadowBoxing: DateTime(2000)},
      );

      final workout = recommendWorkout(stats, Difficulty.beginner, now: now);

      expect(workout.type, TrainingType.heavyBag);
    },
  );

  test('the returned workout always comes from the bundled library', () {
    final workout = recommendWorkout(
      _stats(),
      Difficulty.intermediate,
      now: now,
    );

    expect(findWorkout(workout.id), isNotNull);
  });
}
