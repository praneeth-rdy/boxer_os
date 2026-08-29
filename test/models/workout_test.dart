import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/workout_library.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/round_cue.dart';
import 'package:boxer_os/models/round_spec.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/models/workout.dart';

void main() {
  group('Workout.quick', () {
    test('clamps rounds, workSeconds and restSeconds to their bounds', () {
      final workout = Workout.quick(
        rounds: 0,
        workSeconds: 5,
        restSeconds: 900,
      );

      expect(workout.roundCount, 1);
      expect(workout.rounds.first.workSeconds, 10);
      expect(workout.rounds.first.restSeconds, 300);
      expect(workout.id, 'quick');
      expect(workout.isCustom, true);
    });

    test('builds the requested number of identical rounds', () {
      final workout = Workout.quick(
        rounds: 3,
        workSeconds: 90,
        restSeconds: 30,
      );

      expect(workout.rounds, [
        const RoundSpec(workSeconds: 90, restSeconds: 30),
        const RoundSpec(workSeconds: 90, restSeconds: 30),
        const RoundSpec(workSeconds: 90, restSeconds: 30),
      ]);
    });
  });

  group('Workout getters', () {
    test(
      'totalSeconds sums prepare plus work and rest, no rest after the last round',
      () {
        const workout = Workout(
          id: 'w',
          name: 'W',
          type: TrainingType.custom,
          difficulty: Difficulty.beginner,
          prepareSeconds: 10,
          rounds: [
            RoundSpec(workSeconds: 120, restSeconds: 60),
            RoundSpec(workSeconds: 120, restSeconds: 60),
            RoundSpec(workSeconds: 120, restSeconds: 60),
          ],
        );

        expect(workout.totalSeconds, 10 + 3 * 120 + 2 * 60);
        expect(workout.totalSeconds, 490);
      },
    );

    test('roundCount and hasCues reflect the round list', () {
      const withCues = Workout(
        id: 'w',
        name: 'W',
        type: TrainingType.custom,
        difficulty: Difficulty.beginner,
        rounds: [
          RoundSpec(
            workSeconds: 60,
            restSeconds: 30,
            cues: [RoundCue(atSecond: 5, text: '1')],
          ),
        ],
      );
      const withoutCues = Workout(
        id: 'w',
        name: 'W',
        type: TrainingType.custom,
        difficulty: Difficulty.beginner,
        rounds: [RoundSpec(workSeconds: 60, restSeconds: 30)],
      );

      expect(withCues.roundCount, 1);
      expect(withCues.hasCues, true);
      expect(withoutCues.hasCues, false);
    });

    test('estimatedMinutes rounds up total seconds to whole minutes', () {
      const workout = Workout(
        id: 'w',
        name: 'W',
        type: TrainingType.custom,
        difficulty: Difficulty.beginner,
        prepareSeconds: 0,
        rounds: [RoundSpec(workSeconds: 61, restSeconds: 0)],
      );

      expect(workout.estimatedMinutes, 2);
    });
  });

  group('Workout.copyWith', () {
    test('replaces only the given fields', () {
      const original = Workout(
        id: 'shadow_foundations',
        name: 'Original',
        type: TrainingType.shadowBoxing,
        difficulty: Difficulty.beginner,
        rounds: [RoundSpec(workSeconds: 120, restSeconds: 60)],
      );

      final copy = original.copyWith(
        name: 'Renamed',
        difficulty: Difficulty.advanced,
      );

      expect(copy.name, 'Renamed');
      expect(copy.difficulty, Difficulty.advanced);
      expect(copy.id, original.id);
      expect(copy.rounds, original.rounds);
    });
  });

  group('Workout JSON round trip', () {
    test(
      'fromJson(toJson()) equals the original for every library workout',
      () {
        for (final workout in workoutLibrary) {
          final restored = Workout.fromJson(workout.toJson());

          expect(
            restored.toJson(),
            workout.toJson(),
            reason: 'round trip mismatch for ${workout.id}',
          );
        }
      },
    );

    test(
      'fromJson defaults missing fields and falls back unknown enums to custom',
      () {
        final workout = Workout.fromJson(const {
          'id': 'x',
          'name': 'X',
          'type': 'not_a_real_type',
          'difficulty': 'not_a_real_difficulty',
        });

        expect(workout.type, TrainingType.custom);
        expect(workout.difficulty, Difficulty.beginner);
        expect(workout.rounds, isEmpty);
        expect(workout.prepareSeconds, 10);
        expect(workout.isCustom, false);
      },
    );
  });
}
