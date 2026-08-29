import 'package:flutter/foundation.dart';

import 'round_cue.dart';

/// One round of a workout: its work and rest lengths, title and cues.
class RoundSpec {
  const RoundSpec({
    required this.workSeconds,
    required this.restSeconds,
    this.focus = '',
    this.cues = const [],
  });

  factory RoundSpec.fromJson(Map<String, dynamic> json) => RoundSpec(
    workSeconds: json['work'] as int? ?? 0,
    restSeconds: json['rest'] as int? ?? 0,
    focus: json['focus'] as String? ?? '',
    cues: ((json['cues'] as List<dynamic>?) ?? const [])
        .map((cue) => RoundCue.fromJson(cue as Map<String, dynamic>))
        .toList(growable: false),
  );

  final int workSeconds;
  final int restSeconds;

  /// Short round title shown while no cue is active.
  final String focus;

  final List<RoundCue> cues;

  Map<String, dynamic> toJson() => {
    'work': workSeconds,
    'rest': restSeconds,
    'focus': focus,
    'cues': cues.map((cue) => cue.toJson()).toList(growable: false),
  };

  @override
  bool operator ==(Object other) =>
      other is RoundSpec &&
      other.workSeconds == workSeconds &&
      other.restSeconds == restSeconds &&
      other.focus == focus &&
      listEquals(other.cues, cues);

  @override
  int get hashCode =>
      Object.hash(workSeconds, restSeconds, focus, Object.hashAll(cues));
}
