import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/combination.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/utils/practice_builder.dart';

const Combination _comboA = Combination(
  moves: ['1'],
  difficulty: Difficulty.beginner,
  seed: 0,
  id: 'a',
  name: 'A',
);

const Combination _comboB = Combination(
  moves: ['2'],
  difficulty: Difficulty.beginner,
  seed: 0,
  id: 'b',
  name: 'B',
);

void main() {
  group('buildPracticeWorkout', () {
    test('sets the workout metadata', () {
      final workout = buildPracticeWorkout(
        combinations: const [_comboA],
        rounds: 2,
        roundSeconds: 60,
        difficulty: Difficulty.intermediate,
      );

      expect(workout.id, 'combo_practice');
      expect(workout.name, 'Combo practice');
      expect(workout.type, TrainingType.shadowBoxing);
      expect(workout.difficulty, Difficulty.intermediate);
      expect(workout.isCustom, isTrue);
      expect(workout.roundCount, 2);
    });

    test('a custom name overrides the default', () {
      final workout = buildPracticeWorkout(
        combinations: const [_comboA],
        rounds: 1,
        roundSeconds: 60,
        difficulty: Difficulty.beginner,
        name: 'Saved drill',
      );

      expect(workout.name, 'Saved drill');
    });

    test(
      '2 combos over 2 x 60s rounds cue at 3, 23, 43 cycling A, B, A / B, A, B',
      () {
        final workout = buildPracticeWorkout(
          combinations: const [_comboA, _comboB],
          rounds: 2,
          roundSeconds: 60,
          difficulty: Difficulty.beginner,
        );

        expect(workout.rounds, hasLength(2));

        final firstRound = workout.rounds[0].cues;
        expect(firstRound.map((cue) => cue.atSecond), [3, 23, 43]);
        expect(firstRound.map((cue) => cue.text), [
          _comboA.notation,
          _comboB.notation,
          _comboA.notation,
        ]);

        final secondRound = workout.rounds[1].cues;
        expect(secondRound.map((cue) => cue.atSecond), [3, 23, 43]);
        expect(secondRound.map((cue) => cue.text), [
          _comboB.notation,
          _comboA.notation,
          _comboB.notation,
        ]);
      },
    );

    test('rest seconds and focus are set per round', () {
      final workout = buildPracticeWorkout(
        combinations: const [_comboA],
        rounds: 2,
        roundSeconds: 60,
        difficulty: Difficulty.beginner,
      );

      expect(workout.rounds[0].restSeconds, 45);
      expect(workout.rounds[0].focus, 'Combo round 1');
      expect(workout.rounds[1].restSeconds, 45);
      expect(workout.rounds[1].focus, 'Combo round 2');
    });

    test('an empty combination list produces rounds with no cues', () {
      final workout = buildPracticeWorkout(
        combinations: const [],
        rounds: 2,
        roundSeconds: 60,
        difficulty: Difficulty.beginner,
      );

      expect(workout.rounds, hasLength(2));
      for (final round in workout.rounds) {
        expect(round.cues, isEmpty);
        expect(round.focus, isNotEmpty);
      }
    });
  });
}
