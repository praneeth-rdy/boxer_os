import 'dart:math';

import '../data/boxing_grammar.dart';
import '../data/boxing_vocabulary.dart';
import '../models/combination.dart';
import '../models/difficulty.dart';

const double _beginnerDefenseChance = 0.3;
const double _advancedExitChance = 0.5;

/// Builds the combination [seed] produces at [difficulty]; same seed, same moves.
Combination generateCombination({
  required Difficulty difficulty,
  required int seed,
}) {
  final random = Random(seed);
  final moves = switch (difficulty) {
    Difficulty.beginner => _beginnerMoves(random),
    Difficulty.intermediate => _intermediateMoves(random),
    Difficulty.advanced => _advancedMoves(random),
  };
  return Combination(moves: moves, difficulty: difficulty, seed: seed);
}

/// Builds [count] combinations from the consecutive seeds starting at [seed].
List<Combination> generateCombinationSet({
  required Difficulty difficulty,
  required int seed,
  required int count,
}) => [
  for (var index = 0; index < count; index++)
    generateCombination(difficulty: difficulty, seed: seed + index),
];

List<String> _beginnerMoves(Random random) {
  final punchCount = 2 + random.nextInt(2);
  final moves = _chain(
    random,
    beginnerPunches,
    starters: openers,
    length: punchCount,
  );
  if (punchCount == 2 && random.nextDouble() < _beginnerDefenseChance) {
    moves.add(_pick(random, beginnerDefense));
  }
  return moves;
}

List<String> _intermediateMoves(Random random) => _movesWithDefense(
  random,
  punches: intermediatePunches,
  defenses: intermediateDefense,
  length: 3 + random.nextInt(2),
  defenseCount: 1,
);

List<String> _advancedMoves(Random random) {
  final length = 4 + random.nextInt(3);
  final hasExit = random.nextDouble() < _advancedExitChance;
  final coreLength = hasExit ? length - 1 : length;
  // Two defenses need punches around and between them: p, d, p, d, p.
  final defenseCount = coreLength >= 5 && random.nextBool() ? 2 : 1;
  final moves = _movesWithDefense(
    random,
    punches: advancedPunches,
    defenses: advancedDefense,
    length: coreLength,
    defenseCount: defenseCount,
  );
  if (hasExit) {
    moves.add(_pick(random, exits));
  }
  return moves;
}

/// Punch chains split by [defenseCount] defenses, never first, last or adjacent.
List<String> _movesWithDefense(
  Random random, {
  required List<String> punches,
  required List<String> defenses,
  required int length,
  required int defenseCount,
}) {
  final chainCount = defenseCount + 1;
  final sizes = List<int>.filled(chainCount, 1);
  for (var spare = length - defenseCount - chainCount; spare > 0; spare--) {
    sizes[random.nextInt(chainCount)]++;
  }
  final moves = <String>[];
  var starters = openers;
  for (var chain = 0; chain < chainCount; chain++) {
    if (chain > 0) {
      final defense = _pick(random, defenses);
      moves.add(defense);
      starters = punchesAfterDefense[defense] ?? punches;
    }
    moves.addAll(
      _chain(random, punches, starters: starters, length: sizes[chain]),
    );
  }
  return moves;
}

/// Grows a chain of [length] punches, each one allowed to follow the last.
List<String> _chain(
  Random random,
  List<String> punches, {
  required List<String> starters,
  required int length,
}) {
  final options = starters.where(punches.contains).toList(growable: false);
  final chain = <String>[_pick(random, options)];
  while (chain.length < length) {
    final isLast = chain.length == length - 1;
    final candidates = punches
        .where(
          (punch) =>
              canExtendChain(chain, punch) &&
              (!isLast || chainEndsLegally([...chain, punch])),
        )
        .toList(growable: false);
    if (candidates.isEmpty) break;
    chain.add(
      _pick(random, isLast ? _preferredEnders(candidates) : candidates),
    );
  }
  // A chain only stops short when nothing legal follows: end it where it can.
  while (chain.length > 1 && !chainEndsLegally(chain)) {
    chain.removeLast();
  }
  return chain;
}

/// A chain lands better on a head shot that is not the jab, where one is legal.
List<String> _preferredEnders(List<String> candidates) {
  final preferred = candidates
      .where((punch) => punch != '1' && !isBodyShot(punch))
      .toList(growable: false);
  return preferred.isEmpty ? candidates : preferred;
}

T _pick<T>(Random random, List<T> options) =>
    options[random.nextInt(options.length)];
