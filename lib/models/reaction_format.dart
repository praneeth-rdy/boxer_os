/// How long a reaction test runs.
enum ReactionFormat {
  standard,
  endurance;

  String get label => switch (this) {
    ReactionFormat.standard => '10 trials',
    ReactionFormat.endurance => 'Endurance 60',
  };

  /// Falls back to standard when the stored name is missing or unknown.
  static ReactionFormat fromName(String? name) => values.firstWhere(
    (format) => format.name == name,
    orElse: () => values.first,
  );
}
