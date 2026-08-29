/// Midnight at the start of [date]'s calendar day.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// True when both instants fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Monday 00:00 of the week [date] falls in.
DateTime startOfWeek(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

/// Days since 1 January of [date]'s year, 0 on 1 January. Counted in UTC so a
/// daylight saving shift cannot drop a day.
int dayOfYear(DateTime date) => DateTime.utc(
  date.year,
  date.month,
  date.day,
).difference(DateTime.utc(date.year)).inDays;
