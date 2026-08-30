/// What a day in the boxing calendar marks.
enum EventKind {
  anniversary,
  birthday,
  memorial,
  internationalDay;

  String get label => switch (this) {
    EventKind.anniversary => 'Anniversary',
    EventKind.birthday => 'Born',
    EventKind.memorial => 'Remembered',
    EventKind.internationalDay => 'International day',
  };
}

/// One dated moment in boxing, shown again on its day every year.
class BoxingEvent {
  const BoxingEvent({
    required this.month,
    required this.day,
    this.year,
    required this.title,
    required this.blurb,
    required this.kind,
    this.legendId,
  });

  final int month;
  final int day;

  /// The year it happened; null for a day that recurs without one.
  final int? year;
  final String title;
  final String blurb;
  final EventKind kind;

  /// The legend this day belongs to, when one of the bundled twelve owns it.
  final String? legendId;

  /// The kind, with the year when there is one: "Anniversary · 1974".
  String get subtitle => year == null ? kind.label : '${kind.label} · $year';
}
