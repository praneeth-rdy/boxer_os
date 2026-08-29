import 'dart:math';

import 'package:flutter/foundation.dart';

import 'reaction_format.dart';
import 'reaction_mode.dart';

/// One finished reaction test: the times that landed and what went wrong.
class ReactionResult {
  const ReactionResult({
    required this.mode,
    required this.completedAt,
    required this.reactionMillis,
    required this.falseStarts,
    required this.misses,
    this.format = ReactionFormat.standard,
    this.correctHolds = 0,
    this.falseAlarms = 0,
    this.durationSeconds = 0,
  });

  factory ReactionResult.fromJson(Map<String, dynamic> json) => ReactionResult(
    mode: ReactionMode.fromName(json['mode'] as String?),
    completedAt:
        DateTime.tryParse(json['completed_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    reactionMillis: ((json['reaction_millis'] as List<dynamic>?) ?? const [])
        .map((millis) => millis as int)
        .toList(growable: false),
    falseStarts: json['false_starts'] as int? ?? 0,
    misses: json['misses'] as int? ?? 0,
    format: ReactionFormat.fromName(json['format'] as String?),
    correctHolds: json['correct_holds'] as int? ?? 0,
    falseAlarms: json['false_alarms'] as int? ?? 0,
    durationSeconds: json['duration_seconds'] as int? ?? 0,
  );

  final ReactionMode mode;
  final ReactionFormat format;
  final DateTime completedAt;

  /// Reaction time of every trial that was hit, in order; misses are not here.
  final List<int> reactionMillis;

  final int falseStarts;
  final int misses;

  /// Hold stimuli left alone in go / no-go, neither a hit nor a miss.
  final int correctHolds;

  /// Hold stimuli tapped anyway in go / no-go.
  final int falseAlarms;

  /// How long the test took, first stimulus to last response.
  final int durationSeconds;

  int get trials => reactionMillis.length + misses + correctHolds + falseAlarms;

  int? get bestMillis =>
      reactionMillis.isEmpty ? null : reactionMillis.reduce(min);

  int? get averageMillis => _average(reactionMillis);

  /// Average of the first half of the hits, null under four hits.
  int? get firstHalfAverage => _average(reactionMillis.take(_halfLength));

  /// Average of the last half of the hits, null under four hits.
  int? get secondHalfAverage =>
      _average(reactionMillis.skip(reactionMillis.length - _halfLength));

  /// How much slower the second half ran than the first, as a percentage.
  int? get decayPercent {
    final first = firstHalfAverage;
    final second = secondHalfAverage;
    if (first == null || second == null) {
      return null;
    }
    return (second - first) * 100 ~/ first;
  }

  /// Hits over the trials that asked for one, null when none did.
  double? get accuracy {
    final asked = reactionMillis.length + misses + falseAlarms;
    return asked == 0 ? null : reactionMillis.length / asked;
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'format': format.name,
    'completed_at': completedAt.toIso8601String(),
    'reaction_millis': reactionMillis,
    'false_starts': falseStarts,
    'misses': misses,
    'correct_holds': correctHolds,
    'false_alarms': falseAlarms,
    'duration_seconds': durationSeconds,
  };

  /// An odd hit drops its middle time so both halves span the same count.
  int get _halfLength =>
      reactionMillis.length < _minHalvesHits ? 0 : reactionMillis.length ~/ 2;

  static const int _minHalvesHits = 4;

  static int? _average(Iterable<int> millis) {
    if (millis.isEmpty) {
      return null;
    }
    return (millis.reduce((sum, value) => sum + value) / millis.length).round();
  }

  @override
  bool operator ==(Object other) =>
      other is ReactionResult &&
      other.mode == mode &&
      other.format == format &&
      other.completedAt == completedAt &&
      listEquals(other.reactionMillis, reactionMillis) &&
      other.falseStarts == falseStarts &&
      other.misses == misses &&
      other.correctHolds == correctHolds &&
      other.falseAlarms == falseAlarms &&
      other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(
    mode,
    format,
    completedAt,
    Object.hashAll(reactionMillis),
    falseStarts,
    misses,
    correctHolds,
    falseAlarms,
    durationSeconds,
  );
}
