/// How the reaction trainer presents its stimulus.
enum ReactionMode {
  tap,
  direction,
  defense,
  goNoGo;

  String get label => switch (this) {
    ReactionMode.tap => 'Tap',
    ReactionMode.direction => 'Direction',
    ReactionMode.defense => 'Defense',
    ReactionMode.goNoGo => 'Go / No-go',
  };

  String get description => switch (this) {
    ReactionMode.tap => 'Tap anywhere the moment the screen flashes.',
    ReactionMode.direction => 'Tap the edge the arrow points to.',
    ReactionMode.defense => 'A punch is called. Tap the defense that beats it.',
    ReactionMode.goNoGo =>
      'Mint means go, red means hold. Do not bite on the feint.',
  };

  /// Falls back to tap when the stored name is missing or unknown.
  static ReactionMode fromName(String? name) => values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => values.first,
  );
}
