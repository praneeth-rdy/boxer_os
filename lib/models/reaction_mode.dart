/// How the reaction trainer presents its stimulus.
enum ReactionMode {
  tap,
  direction,
  defense,
  goNoGo,
  peripheral,
  colour,
  sequence,
  sound;

  String get label => switch (this) {
    ReactionMode.tap => 'Tap',
    ReactionMode.direction => 'Direction',
    ReactionMode.defense => 'Defense',
    ReactionMode.goNoGo => 'Go / No-go',
    ReactionMode.peripheral => 'Peripheral',
    ReactionMode.colour => 'Colour call',
    ReactionMode.sequence => 'Sequence',
    ReactionMode.sound => 'Sound',
  };

  String get description => switch (this) {
    ReactionMode.tap => 'Tap anywhere the moment the screen flashes.',
    ReactionMode.direction => 'Tap the edge the arrow points to.',
    ReactionMode.defense => 'A punch is called. Tap the defense that beats it.',
    ReactionMode.goNoGo =>
      'Mint means go, red means hold. Do not bite on the feint.',
    ReactionMode.peripheral => 'A dot appears anywhere. Tap it.',
    ReactionMode.colour => 'Tap the ink colour, not the word.',
    ReactionMode.sequence => 'Watch the arrows, then tap them back in order.',
    ReactionMode.sound => 'Screen dark. Tap when you hear the beep.',
  };

  /// Whether the mode trains a ring skill rather than raw speed.
  bool get isBoxing =>
      this == ReactionMode.defense ||
      this == ReactionMode.goNoGo ||
      this == ReactionMode.sequence;

  /// Falls back to tap when the stored name is missing or unknown.
  static ReactionMode fromName(String? name) => values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => values.first,
  );
}
