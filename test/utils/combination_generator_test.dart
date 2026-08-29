import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_grammar.dart';
import 'package:boxer_os/data/boxing_vocabulary.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/utils/combination_generator.dart';

const int _seedCount = 300;

const Map<Difficulty, (int, int)> _lengthRange = {
  Difficulty.beginner: (2, 3),
  Difficulty.intermediate: (3, 4),
  Difficulty.advanced: (4, 6),
};

// The three-punch beginner vocabulary cannot reach the same variety as the
// larger intermediate and advanced lists, so its threshold is lower.
const Map<Difficulty, int> _distinctThreshold = {
  Difficulty.beginner: 10,
  Difficulty.intermediate: 15,
  Difficulty.advanced: 15,
};

void main() {
  group('determinism', () {
    for (final difficulty in Difficulty.values) {
      test('same seed produces an equal combination for $difficulty', () {
        final first = generateCombination(difficulty: difficulty, seed: 7);
        final second = generateCombination(difficulty: difficulty, seed: 7);

        expect(first, second);
        expect(first.moves, second.moves);
      });

      test(
        'seeds 0..19 usually produce distinct notations for $difficulty',
        () {
          final notations = {
            for (var seed = 0; seed < 20; seed++)
              generateCombination(difficulty: difficulty, seed: seed).notation,
          };

          expect(
            notations.length,
            greaterThanOrEqualTo(_distinctThreshold[difficulty]!),
          );
        },
      );
    }
  });

  group('structure over 300 seeds', () {
    for (final difficulty in Difficulty.values) {
      test('every combination is well-formed for $difficulty', () {
        final (minLength, maxLength) = _lengthRange[difficulty]!;

        for (var seed = 0; seed < _seedCount; seed++) {
          final combination = generateCombination(
            difficulty: difficulty,
            seed: seed,
          );
          final moves = combination.moves;

          expect(moves, isNotEmpty);
          expect(isPunch(moves.first), isTrue, reason: 'seed $seed: $moves');
          expect(
            isValidCombination(moves),
            isTrue,
            reason: 'seed $seed: $moves fails the grammar',
          );
          expect(
            moves.length,
            inInclusiveRange(minLength, maxLength),
            reason: 'seed $seed: $moves',
          );
          expect(
            moves.length,
            lessThanOrEqualTo(6),
            reason: 'seed $seed: $moves',
          );

          _expectNoAdjacentBodyShots(moves, seed);
          _expectNoChainEndsOnBodyJab(moves, seed);
          _expectOnlyDoubleJabRepeats(moves, seed);
          _expectDifficultyRules(difficulty, moves, seed);
        }
      });
    }
  });

  group('generateCombinationSet', () {
    test('uses seed + index for each combination in the set', () {
      const difficulty = Difficulty.intermediate;
      const seed = 5;
      const count = 4;

      final set = generateCombinationSet(
        difficulty: difficulty,
        seed: seed,
        count: count,
      );

      expect(set.length, count);
      for (var index = 0; index < count; index++) {
        expect(
          set[index],
          generateCombination(difficulty: difficulty, seed: seed + index),
        );
      }
    });

    test('is pure: calling it twice with the same arguments matches', () {
      final first = generateCombinationSet(
        difficulty: Difficulty.advanced,
        seed: 11,
        count: 6,
      );
      final second = generateCombinationSet(
        difficulty: Difficulty.advanced,
        seed: 11,
        count: 6,
      );

      expect(first, second);
    });
  });
}

void _expectNoChainEndsOnBodyJab(List<String> moves, int seed) {
  var chainLength = 0;
  for (var index = 0; index < moves.length; index++) {
    if (!isPunch(moves[index])) {
      chainLength = 0;
      continue;
    }
    chainLength++;
    final endsChain = index == moves.length - 1 || !isPunch(moves[index + 1]);
    if (moves[index] == '1b' && chainLength >= 2) {
      expect(
        endsChain,
        isFalse,
        reason: 'seed $seed: $moves ends a chain on the body jab',
      );
    }
  }
}

void _expectNoAdjacentBodyShots(List<String> moves, int seed) {
  for (var index = 1; index < moves.length; index++) {
    final previous = moves[index - 1];
    final current = moves[index];
    if (isBodyShot(previous)) {
      expect(
        isBodyShot(current),
        isFalse,
        reason: 'seed $seed: $moves has adjacent body shots',
      );
    }
  }
}

void _expectOnlyDoubleJabRepeats(List<String> moves, int seed) {
  for (var index = 1; index < moves.length; index++) {
    final previous = moves[index - 1];
    final current = moves[index];
    if (isPunch(previous) && isPunch(current) && previous == current) {
      expect(
        current,
        '1',
        reason: 'seed $seed: $moves repeats a punch other than 1-1',
      );
    }
  }
}

void _expectDifficultyRules(
  Difficulty difficulty,
  List<String> moves,
  int seed,
) {
  switch (difficulty) {
    case Difficulty.beginner:
      _expectBeginnerRules(moves, seed);
    case Difficulty.intermediate:
      _expectExactlyOneInteriorDefense(moves, intermediateDefense, seed);
    case Difficulty.advanced:
      _expectAdvancedDefenses(moves, seed);
  }
}

void _expectBeginnerRules(List<String> moves, int seed) {
  for (var index = 0; index < moves.length; index++) {
    final move = moves[index];
    final isLast = index == moves.length - 1;
    if (isPunch(move)) {
      expect(
        beginnerPunches.contains(move),
        isTrue,
        reason: 'seed $seed: $moves uses a punch outside 1, 2, 3',
      );
    } else {
      expect(
        isLast,
        isTrue,
        reason: 'seed $seed: $moves has a defense that is not trailing',
      );
      expect(
        beginnerDefense.contains(move),
        isTrue,
        reason: 'seed $seed: $moves has an unknown defense move',
      );
    }
  }
}

void _expectExactlyOneInteriorDefense(
  List<String> moves,
  List<String> defenses,
  int seed,
) {
  final defenseIndexes = [
    for (var index = 0; index < moves.length; index++)
      if (defenses.contains(moves[index])) index,
  ];

  expect(
    defenseIndexes.length,
    1,
    reason: 'seed $seed: $moves should have exactly one defense',
  );
  expect(defenseIndexes.single, isNot(0), reason: 'seed $seed: $moves');
  expect(
    defenseIndexes.single,
    isNot(moves.length - 1),
    reason: 'seed $seed: $moves',
  );
}

void _expectAdvancedDefenses(List<String> moves, int seed) {
  // A defense move is never first or last, and the generator only ever
  // appends an exit token after the core moves, so a trailing 'pivot' (which
  // is both a defense and an exit token) is unambiguously an exit when it is
  // the last move. Restricting the scan to interior indexes sidesteps that.
  final defenseIndexes = [
    for (var index = 1; index < moves.length - 1; index++)
      if (advancedDefense.contains(moves[index])) index,
  ];

  expect(
    defenseIndexes.length,
    inInclusiveRange(1, 2),
    reason: 'seed $seed: $moves should have 1 or 2 defenses',
  );
  if (defenseIndexes.length == 2) {
    expect(
      defenseIndexes[1] - defenseIndexes[0],
      greaterThan(1),
      reason: 'seed $seed: $moves has adjacent defenses',
    );
  }
}
