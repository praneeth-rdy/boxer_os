import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_grammar.dart';
import 'package:boxer_os/data/combination_library.dart';
import 'package:boxer_os/models/combo_tag.dart';
import 'package:boxer_os/models/difficulty.dart';

void main() {
  test('the library has sixty entries', () {
    expect(combinationLibrary.length, 60);
  });

  test('ids are unique and in order c01..c60', () {
    final ids = [for (final combination in combinationLibrary) combination.id];
    final expectedIds = [
      for (var index = 1; index <= 60; index++)
        'c${index.toString().padLeft(2, '0')}',
    ];

    expect(ids, expectedIds);
    expect(ids.toSet().length, 60);
  });

  test('every entry passes isValidCombination', () {
    for (final combination in combinationLibrary) {
      expect(
        isValidCombination(combination.moves),
        isTrue,
        reason: '${combination.id} (${combination.moves}) is not valid boxing',
      );
    }
  });

  test('every entry has a non-empty name, description and at least one tag', () {
    for (final combination in combinationLibrary) {
      expect(combination.name, isNotEmpty, reason: combination.id);
      expect(combination.description, isNotEmpty, reason: combination.id);
      expect(combination.tags, isNotEmpty, reason: combination.id);
    }
  });

  test('difficulty counts are 15 beginner, 25 intermediate, 20 advanced', () {
    final counts = <Difficulty, int>{};
    for (final combination in combinationLibrary) {
      counts[combination.difficulty] = (counts[combination.difficulty] ?? 0) + 1;
    }

    expect(counts[Difficulty.beginner], 15);
    expect(counts[Difficulty.intermediate], 25);
    expect(counts[Difficulty.advanced], 20);
  });

  group('findCombination', () {
    test('c03 is the one-two', () {
      final combination = findCombination('c03');

      expect(combination, isNotNull);
      expect(combination!.moves, ['1', '2']);
    });

    test('an unknown id returns null', () {
      expect(findCombination('nope'), isNull);
    });
  });

  group('combinationsWhere', () {
    test('filters by difficulty', () {
      final beginners = combinationsWhere(difficulty: Difficulty.beginner);

      expect(beginners.length, 15);
      expect(
        beginners.every((combination) => combination.difficulty == Difficulty.beginner),
        isTrue,
      );
    });

    test('filters by tag', () {
      final offense = combinationsWhere(tag: ComboTag.offense);

      expect(offense, isNotEmpty);
      expect(
        offense.every((combination) => combination.tags.contains(ComboTag.offense)),
        isTrue,
      );
    });

    test('filters by difficulty and tag together', () {
      final result = combinationsWhere(
        difficulty: Difficulty.intermediate,
        tag: ComboTag.body,
      );

      expect(result, isNotEmpty);
      expect(
        result.every(
          (combination) =>
              combination.difficulty == Difficulty.intermediate &&
              combination.tags.contains(ComboTag.body),
        ),
        isTrue,
      );
    });

    test('returns all sixty when no filter is given', () {
      expect(combinationsWhere().length, 60);
    });
  });
}
