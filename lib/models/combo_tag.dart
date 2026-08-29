/// What a library combination is built around.
enum ComboTag {
  offense,
  counter,
  body,
  defense,
  movement;

  String get label => switch (this) {
    ComboTag.offense => 'Offense',
    ComboTag.counter => 'Counter',
    ComboTag.body => 'Body',
    ComboTag.defense => 'Defense',
    ComboTag.movement => 'Movement',
  };

  /// Falls back to offense when the stored name is missing or unknown.
  static ComboTag fromName(String? name) =>
      values.firstWhere((tag) => tag.name == name, orElse: () => values.first);
}
