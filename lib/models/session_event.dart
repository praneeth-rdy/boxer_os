/// Something the session engine announces as it runs.
enum SessionEventType {
  prepareStarted,
  roundStarted,
  tenSecondWarning,
  finalThirty,
  cue,
  restStarted,
  roundSkipped,
  paused,
  resumed,
  sessionCompleted,
  sessionEnded,
}

/// One announcement from the session engine, tagged with the round it belongs to.
class SessionEvent {
  const SessionEvent(this.type, {required this.round, this.cueText});

  final SessionEventType type;

  /// 1-based round, 0 before the first round starts.
  final int round;

  /// Set only on [SessionEventType.cue].
  final String? cueText;

  @override
  bool operator ==(Object other) =>
      other is SessionEvent &&
      other.type == type &&
      other.round == round &&
      other.cueText == cueText;

  @override
  int get hashCode => Object.hash(type, round, cueText);

  @override
  String toString() =>
      'SessionEvent(${type.name}, round: $round'
      '${cueText == null ? '' : ", cue: $cueText"})';
}
