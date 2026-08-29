import 'difficulty.dart';
import 'stance.dart';
import 'training_type.dart';

/// One finished (or abandoned) session, as stored in training history.
class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.type,
    required this.difficulty,
    required this.stance,
    required this.startedAt,
    required this.durationSeconds,
    required this.roundsCompleted,
    required this.roundsPlanned,
    required this.completed,
    this.rating,
    this.whatWorked,
    this.whatNeedsWork,
    this.opponent,
    this.opponentStance,
  });

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    id: json['id'] as String? ?? '',
    workoutId: json['workout_id'] as String? ?? '',
    workoutName: json['workout_name'] as String? ?? '',
    type: TrainingType.fromName(json['type'] as String?),
    difficulty: Difficulty.fromName(json['difficulty'] as String?),
    stance: Stance.fromName(json['stance'] as String?),
    startedAt:
        DateTime.tryParse(json['started_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    durationSeconds: json['duration_seconds'] as int? ?? 0,
    roundsCompleted: json['rounds_completed'] as int? ?? 0,
    roundsPlanned: json['rounds_planned'] as int? ?? 0,
    completed: json['completed'] as bool? ?? false,
    rating: json['rating'] as int?,
    whatWorked: json['what_worked'] as String?,
    whatNeedsWork: json['what_needs_work'] as String?,
    opponent: json['opponent'] as String?,
    opponentStance: json['opponent_stance'] == null
        ? null
        : Stance.fromName(json['opponent_stance'] as String?),
  );

  /// `startedAt.millisecondsSinceEpoch` as a string.
  final String id;

  final String workoutId;
  final String workoutName;
  final TrainingType type;
  final Difficulty difficulty;
  final Stance stance;
  final DateTime startedAt;

  /// Elapsed training time, pauses excluded.
  final int durationSeconds;

  /// Rounds whose work phase finished.
  final int roundsCompleted;

  final int roundsPlanned;

  /// False when the boxer ended the session early.
  final bool completed;

  /// How the session felt, 1 to 5.
  final int? rating;

  final String? whatWorked;
  final String? whatNeedsWork;

  /// Who was sparred, on sparring sessions only.
  final String? opponent;

  final Stance? opponentStance;

  int get workMinutes => (durationSeconds / 60).round();

  SessionRecord copyWith({
    int? rating,
    String? whatWorked,
    String? whatNeedsWork,
    String? opponent,
    Stance? opponentStance,
  }) => SessionRecord(
    id: id,
    workoutId: workoutId,
    workoutName: workoutName,
    type: type,
    difficulty: difficulty,
    stance: stance,
    startedAt: startedAt,
    durationSeconds: durationSeconds,
    roundsCompleted: roundsCompleted,
    roundsPlanned: roundsPlanned,
    completed: completed,
    rating: rating ?? this.rating,
    whatWorked: whatWorked ?? this.whatWorked,
    whatNeedsWork: whatNeedsWork ?? this.whatNeedsWork,
    opponent: opponent ?? this.opponent,
    opponentStance: opponentStance ?? this.opponentStance,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workout_id': workoutId,
    'workout_name': workoutName,
    'type': type.name,
    'difficulty': difficulty.name,
    'stance': stance.name,
    'started_at': startedAt.toIso8601String(),
    'duration_seconds': durationSeconds,
    'rounds_completed': roundsCompleted,
    'rounds_planned': roundsPlanned,
    'completed': completed,
    if (rating != null) 'rating': rating,
    if (whatWorked != null) 'what_worked': whatWorked,
    if (whatNeedsWork != null) 'what_needs_work': whatNeedsWork,
    if (opponent != null) 'opponent': opponent,
    if (opponentStance != null) 'opponent_stance': opponentStance?.name,
  };
}
