/// A coaching prompt delivered at a point inside a round's work phase.
class RoundCue {
  const RoundCue({required this.atSecond, required this.text});

  factory RoundCue.fromJson(Map<String, dynamic> json) => RoundCue(
    atSecond: json['at'] as int? ?? 0,
    text: json['text'] as String? ?? '',
  );

  /// Seconds elapsed since the work phase started.
  final int atSecond;

  /// Cue notation, spoken aloud and shown on screen.
  final String text;

  Map<String, dynamic> toJson() => {'at': atSecond, 'text': text};

  @override
  bool operator ==(Object other) =>
      other is RoundCue && other.atSecond == atSecond && other.text == text;

  @override
  int get hashCode => Object.hash(atSecond, text);
}
