import 'package:flutter/foundation.dart';

import '../data/boxing_vocabulary.dart';
import '../utils/cue_speech.dart';
import 'combo_tag.dart';
import 'difficulty.dart';

/// A combination: its moves in cue notation, its level and, for library
/// entries, the identity and coaching notes that go with them.
class Combination {
  const Combination({
    required this.moves,
    required this.difficulty,
    required this.seed,
    this.id = '',
    this.name = '',
    this.description = '',
    this.tags = const [],
  });

  factory Combination.fromJson(Map<String, dynamic> json) => Combination(
    moves: ((json['moves'] as List<dynamic>?) ?? const [])
        .map((move) => move as String)
        .toList(growable: false),
    difficulty: Difficulty.fromName(json['difficulty'] as String?),
    seed: json['seed'] as int? ?? 0,
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    tags: ((json['tags'] as List<dynamic>?) ?? const [])
        .map((tag) => ComboTag.fromName(tag as String?))
        .toList(growable: false),
  );

  /// Punches and movement in throwing order, one token per move.
  final List<String> moves;

  final Difficulty difficulty;

  /// The seed that produced this combination, so it can be thrown again.
  final int seed;

  /// The library id (`c01`), empty for a generated combination.
  final String id;

  final String name;

  /// One line of coaching on how the combination is thrown.
  final String description;

  final List<ComboTag> tags;

  bool get isFromLibrary => id.isNotEmpty;

  /// The moves as one cue: punch chains joined with `-`, the rest by `, `.
  String get notation {
    final parts = <String>[];
    final chain = <String>[];
    for (final move in moves) {
      if (isPunch(move)) {
        chain.add(move);
        continue;
      }
      if (chain.isNotEmpty) {
        parts.add(chain.join('-'));
        chain.clear();
      }
      parts.add(move);
    }
    if (chain.isNotEmpty) {
      parts.add(chain.join('-'));
    }
    return parts.join(', ');
  }

  /// The notation as words, ready for the voice service.
  String get spoken => cueToSpeech(notation);

  int get punchCount => moves.where(isPunch).length;

  Map<String, dynamic> toJson() => {
    'moves': moves,
    'difficulty': difficulty.name,
    'seed': seed,
    if (id.isNotEmpty) 'id': id,
    if (name.isNotEmpty) 'name': name,
    if (description.isNotEmpty) 'description': description,
    if (tags.isNotEmpty) 'tags': [for (final tag in tags) tag.name],
  };

  @override
  bool operator ==(Object other) {
    if (other is! Combination) return false;
    if (id.isNotEmpty || other.id.isNotEmpty) return other.id == id;
    return listEquals(other.moves, moves) && other.difficulty == difficulty;
  }

  @override
  int get hashCode => id.isNotEmpty
      ? id.hashCode
      : Object.hash(Object.hashAll(moves), difficulty);
}
