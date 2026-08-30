import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_calendar.dart';
import 'package:boxer_os/models/boxing_event.dart';

void main() {
  test('boxingCalendar has 39 entries', () {
    expect(boxingCalendar, hasLength(39));
  });

  test('boxingCalendar is sorted by month then day', () {
    for (var i = 1; i < boxingCalendar.length; i++) {
      final previous = boxingCalendar[i - 1];
      final current = boxingCalendar[i];
      final previousKey = previous.month * 100 + previous.day;
      final currentKey = current.month * 100 + current.day;
      expect(
        currentKey,
        greaterThanOrEqualTo(previousKey),
        reason: '${previous.title} should not come after ${current.title}',
      );
    }
  });

  test('no two entries share a month/day or a title', () {
    final dayKeys = <String>{};
    final titles = <String>{};
    for (final event in boxingCalendar) {
      final dayKey = '${event.month}/${event.day}';
      expect(dayKeys.add(dayKey), isTrue, reason: 'duplicate date $dayKey');
      expect(
        titles.add(event.title),
        isTrue,
        reason: 'duplicate title ${event.title}',
      );
    }
  });

  test('eventsOn(2026-10-30) returns the Rumble in the Jungle', () {
    final events = eventsOn(DateTime(2026, 10, 30));

    expect(events, hasLength(1));
    expect(events.single.title, 'The Rumble in the Jungle');
  });

  test('eventsOn a day with no entries returns nothing', () {
    expect(eventsOn(DateTime(2026, 1, 1)), isEmpty);
  });

  test('nextEvents(2026-12-27) wraps around into January', () {
    final next = nextEvents(DateTime(2026, 12, 27), count: 3);

    expect(next.first.title, 'George Foreman born');
    expect(next.first.month, 1);
    expect(next.first.day, 10);
  });

  test('nextEvents respects the count parameter', () {
    final next = nextEvents(DateTime(2026, 1, 1), count: 2);

    expect(next, hasLength(2));
  });

  test('monthName and monthAbbreviation are 1-indexed', () {
    expect(monthName(1), 'January');
    expect(monthName(12), 'December');
    expect(monthAbbreviation(1), 'Jan');
    expect(monthAbbreviation(9), 'Sep');
  });

  test('EventKind.label reads as expected', () {
    expect(EventKind.anniversary.label, 'Anniversary');
    expect(EventKind.birthday.label, 'Born');
    expect(EventKind.memorial.label, 'Remembered');
    expect(EventKind.internationalDay.label, 'International day');
  });

  test('BoxingEvent.subtitle omits the year when there is none', () {
    final withYear = boxingCalendar.firstWhere((e) => e.year != null);
    final withoutYear = boxingCalendar.firstWhere((e) => e.year == null);

    expect(withYear.subtitle, '${withYear.kind.label} · ${withYear.year}');
    expect(withoutYear.subtitle, withoutYear.kind.label);
  });
}
