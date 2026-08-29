import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/workout_library.dart';
import 'package:boxer_os/models/training_type.dart';

final _snakeCase = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

void main() {
  test('workoutLibrary has twelve workouts', () {
    expect(workoutLibrary.length, 12);
  });

  test('every id is unique and snake_case', () {
    final ids = workoutLibrary.map((workout) => workout.id).toList();

    expect(
      ids.toSet().length,
      ids.length,
      reason: 'duplicate workout id found',
    );
    for (final id in ids) {
      expect(_snakeCase.hasMatch(id), true, reason: '$id is not snake_case');
    }
  });

  test('every workout has at least one round and is not custom', () {
    for (final workout in workoutLibrary) {
      expect(workout.rounds, isNotEmpty, reason: '${workout.id} has no rounds');
      expect(
        workout.isCustom,
        false,
        reason: '${workout.id} should not be custom',
      );
    }
  });

  test('every round respects the minimum work and rest lengths', () {
    for (final workout in workoutLibrary) {
      for (final round in workout.rounds) {
        final minimumWork = workout.type == TrainingType.conditioning ? 60 : 30;
        expect(
          round.workSeconds,
          greaterThanOrEqualTo(minimumWork),
          reason: '${workout.id} has a round shorter than $minimumWork s',
        );
        expect(
          round.restSeconds,
          greaterThanOrEqualTo(0),
          reason: '${workout.id} has a negative rest',
        );
      }
    }
  });

  test('cues are sorted, strictly increasing, in range and short', () {
    for (final workout in workoutLibrary) {
      for (final round in workout.rounds) {
        var previousAtSecond = -1;
        for (final cue in round.cues) {
          expect(
            cue.atSecond,
            greaterThan(previousAtSecond),
            reason: '${workout.id} cues are not strictly increasing',
          );
          expect(
            cue.atSecond,
            greaterThan(0),
            reason: '${workout.id} has a cue at or before second 0',
          );
          expect(
            cue.atSecond,
            lessThan(round.workSeconds - 4),
            reason: '${workout.id} has a cue too close to the end of the round',
          );
          expect(
            cue.text.length,
            lessThanOrEqualTo(30),
            reason:
                '${workout.id} cue "${cue.text}" is longer than 30 characters',
          );
          previousAtSecond = cue.atSecond;
        }
      }
    }
  });

  test('estimatedMinutes for footwork_combo_20 is about 20 minutes', () {
    final workout = findWorkout('footwork_combo_20');

    expect(workout, isNotNull);
    expect(workout!.estimatedMinutes, inInclusiveRange(19, 21));
  });

  group('findWorkout', () {
    test('returns the matching workout by id', () {
      final workout = findWorkout('shadow_foundations');

      expect(workout, isNotNull);
      expect(workout!.name, 'Shadow Foundations');
    });

    test('returns null for an unknown id', () {
      expect(findWorkout('not_a_real_workout'), isNull);
    });
  });

  group('workoutsOfType', () {
    test('returns only workouts of the requested type', () {
      final shadowWorkouts = workoutsOfType(TrainingType.shadowBoxing);

      expect(shadowWorkouts, isNotEmpty);
      expect(
        shadowWorkouts.every(
          (workout) => workout.type == TrainingType.shadowBoxing,
        ),
        true,
      );
    });

    test('every training type maps back to at least one workout', () {
      for (final type in TrainingType.values) {
        if (type == TrainingType.custom) continue;
        expect(
          workoutsOfType(type),
          isNotEmpty,
          reason: '$type has no workouts',
        );
      }
    });
  });
}
