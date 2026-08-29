/// How demanding a workout or drill is.
enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.intermediate => 'Intermediate',
    Difficulty.advanced => 'Advanced',
  };

  /// Falls back to beginner when the stored name is missing or unknown.
  static Difficulty fromName(String? name) => values.firstWhere(
    (difficulty) => difficulty.name == name,
    orElse: () => values.first,
  );
}
