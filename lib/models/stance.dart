/// Which side the boxer leads with.
enum Stance {
  orthodox,
  southpaw;

  String get label => switch (this) {
    Stance.orthodox => 'Orthodox',
    Stance.southpaw => 'Southpaw',
  };

  /// Falls back to orthodox when the stored name is missing or unknown.
  static Stance fromName(String? name) => values.firstWhere(
    (stance) => stance.name == name,
    orElse: () => values.first,
  );
}
