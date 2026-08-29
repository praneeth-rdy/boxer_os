/// The kind of work a session or workout consists of.
enum TrainingType {
  shadowBoxing,
  heavyBag,
  speedBag,
  mittWork,
  sparring,
  footwork,
  conditioning,
  strength,
  custom;

  String get label => switch (this) {
    TrainingType.shadowBoxing => 'Shadow boxing',
    TrainingType.heavyBag => 'Heavy bag',
    TrainingType.speedBag => 'Speed bag',
    TrainingType.mittWork => 'Mitt work',
    TrainingType.sparring => 'Sparring',
    TrainingType.footwork => 'Footwork',
    TrainingType.conditioning => 'Conditioning',
    TrainingType.strength => 'Strength',
    TrainingType.custom => 'Custom',
  };

  /// Falls back to custom when the stored name is missing or unknown.
  static TrainingType fromName(String? name) => values.firstWhere(
    (type) => type.name == name,
    orElse: () => TrainingType.custom,
  );
}
