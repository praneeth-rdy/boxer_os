import 'package:boxer_os/models/boxing_event.dart';
import 'package:flutter_test/flutter_test.dart';

BoxingEvent _event({int? year}) => BoxingEvent(
  month: 6,
  day: 1,
  year: year,
  title: 'Title',
  blurb: 'Blurb',
  kind: EventKind.anniversary,
);

void main() {
  group('EventKind.label', () {
    test('maps each kind to its own label', () {
      expect(EventKind.anniversary.label, 'Anniversary');
      expect(EventKind.birthday.label, 'Born');
      expect(EventKind.memorial.label, 'Remembered');
      expect(EventKind.internationalDay.label, 'International day');
    });
  });

  group('BoxingEvent.subtitle', () {
    test('includes the year when one is set', () {
      expect(_event(year: 1974).subtitle, 'Anniversary · 1974');
    });

    test('omits the year and separator when none is set', () {
      expect(_event().subtitle, 'Anniversary');
    });
  });
}
