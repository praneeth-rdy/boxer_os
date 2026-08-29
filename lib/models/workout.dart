import 'difficulty.dart';
import 'round_spec.dart';
import 'training_type.dart';

/// A planned session: an ordered list of rounds with a type and difficulty.
class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.difficulty,
    required this.rounds,
    this.description = '',
    this.prepareSeconds = 10,
    this.isCustom = false,
  });

  /// A plain round timer built from the boxer's own numbers.
  factory Workout.quick({
    required int rounds,
    required int workSeconds,
    required int restSeconds,
  }) {
    final roundCount = rounds.clamp(1, 30);
    final round = RoundSpec(
      workSeconds: workSeconds.clamp(10, 600),
      restSeconds: restSeconds.clamp(0, 300),
    );
    return Workout(
      id: 'quick',
      name: 'Round timer',
      type: TrainingType.custom,
      difficulty: Difficulty.beginner,
      rounds: List.filled(roundCount, round, growable: false),
      isCustom: true,
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    type: TrainingType.fromName(json['type'] as String?),
    difficulty: Difficulty.fromName(json['difficulty'] as String?),
    rounds: ((json['rounds'] as List<dynamic>?) ?? const [])
        .map((round) => RoundSpec.fromJson(round as Map<String, dynamic>))
        .toList(growable: false),
    description: json['description'] as String? ?? '',
    prepareSeconds: json['prepare_seconds'] as int? ?? 10,
    isCustom: json['is_custom'] as bool? ?? false,
  );

  /// Stable snake_case identifier, also stored on every session record.
  final String id;

  final String name;
  final TrainingType type;
  final Difficulty difficulty;
  final List<RoundSpec> rounds;
  final String description;
  final int prepareSeconds;

  /// True for sessions the boxer built, false for every library entry.
  final bool isCustom;

  int get roundCount => rounds.length;

  /// Prepare plus every work and rest phase, with no rest after the last round.
  int get totalSeconds {
    var total = prepareSeconds;
    for (final round in rounds) {
      total += round.workSeconds + round.restSeconds;
    }
    return rounds.isEmpty ? total : total - rounds.last.restSeconds;
  }

  int get estimatedMinutes => (totalSeconds / 60).ceil();

  bool get hasCues => rounds.any((round) => round.cues.isNotEmpty);

  Workout copyWith({
    String? name,
    List<RoundSpec>? rounds,
    Difficulty? difficulty,
  }) => Workout(
    id: id,
    name: name ?? this.name,
    type: type,
    difficulty: difficulty ?? this.difficulty,
    rounds: rounds ?? this.rounds,
    description: description,
    prepareSeconds: prepareSeconds,
    isCustom: isCustom,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'difficulty': difficulty.name,
    'rounds': rounds.map((round) => round.toJson()).toList(growable: false),
    'description': description,
    'prepare_seconds': prepareSeconds,
    'is_custom': isCustom,
  };
}
