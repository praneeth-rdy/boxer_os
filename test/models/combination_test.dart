import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/combination.dart';
import 'package:boxer_os/models/combo_tag.dart';
import 'package:boxer_os/models/difficulty.dart';

void main() {
  group('notation', () {
    test(
      'joins consecutive punches with a hyphen and other moves with a comma',
      () {
        const combination = Combination(
          moves: ['1', '2', 'slip', '3', '2'],
          difficulty: Difficulty.intermediate,
          seed: 1,
        );

        expect(combination.notation, '1-2, slip, 3-2');
      },
    );

    test('a trailing single move joins the last chain with a comma', () {
      const combination = Combination(
        moves: ['1', '2', 'pivot'],
        difficulty: Difficulty.advanced,
        seed: 1,
      );

      expect(combination.notation, '1-2, pivot');
    });
  });

  test('spoken turns the notation into speakable words', () {
    const combination = Combination(
      moves: ['1', '2', 'slip', '3', '2'],
      difficulty: Difficulty.intermediate,
      seed: 1,
    );

    expect(combination.spoken, 'jab, cross, slip, lead hook, cross');
  });

  test('punchCount counts only punch tokens', () {
    const combination = Combination(
      moves: ['1', '2', 'slip', '3', '2'],
      difficulty: Difficulty.intermediate,
      seed: 1,
    );

    expect(combination.punchCount, 4);
  });

  test('toJson and fromJson round-trip moves, difficulty and seed', () {
    const combination = Combination(
      moves: ['1', '2', 'slip', '3', '2'],
      difficulty: Difficulty.advanced,
      seed: 42,
    );

    final restored = Combination.fromJson(combination.toJson());

    expect(restored, combination);
    expect(restored.moves, combination.moves);
    expect(restored.difficulty, combination.difficulty);
    expect(restored.seed, combination.seed);
  });

  test('toJson and fromJson round-trip id, name, description and tags', () {
    const combination = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 0,
      id: 'c03',
      name: 'One-two',
      description: 'Turn the rear hip into the cross.',
      tags: [ComboTag.offense, ComboTag.counter],
    );

    final restored = Combination.fromJson(combination.toJson());

    expect(restored, combination);
    expect(restored.id, 'c03');
    expect(restored.name, 'One-two');
    expect(restored.description, 'Turn the rear hip into the cross.');
    expect(restored.tags, [ComboTag.offense, ComboTag.counter]);
  });

  test('toJson omits id, name, description and tags when empty', () {
    const combination = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 0,
    );

    final json = combination.toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('name'), isFalse);
    expect(json.containsKey('description'), isFalse);
    expect(json.containsKey('tags'), isFalse);
  });

  test('fromJson defaults id, name, description and tags when absent', () {
    final restored = Combination.fromJson({
      'moves': ['1', '2'],
      'difficulty': 'beginner',
      'seed': 0,
    });

    expect(restored.id, '');
    expect(restored.name, '');
    expect(restored.description, '');
    expect(restored.tags, isEmpty);
    expect(restored.isFromLibrary, isFalse);
  });

  test('equality and hashCode compare moves and difficulty, not the seed', () {
    const a = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 1,
    );
    const b = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 1,
    );
    const differentSeed = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 2,
    );
    const differentMoves = Combination(
      moves: ['1', '3'],
      difficulty: Difficulty.beginner,
      seed: 1,
    );
    const differentDifficulty = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.intermediate,
      seed: 1,
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, differentSeed);
    expect(a.hashCode, differentSeed.hashCode);
    expect(a == differentMoves, isFalse);
    expect(a == differentDifficulty, isFalse);
  });

  test('a library combination is equal by id, whatever its moves', () {
    const a = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 1,
      id: 'c01',
    );
    const sameId = Combination(
      moves: ['1', '2', '3'],
      difficulty: Difficulty.advanced,
      seed: 9,
      id: 'c01',
    );
    const otherId = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 1,
      id: 'c02',
    );
    const generated = Combination(
      moves: ['1', '2'],
      difficulty: Difficulty.beginner,
      seed: 1,
    );

    expect(a, sameId);
    expect(a.hashCode, sameId.hashCode);
    expect(a == otherId, isFalse);
    expect(a == generated, isFalse);
  });
}
