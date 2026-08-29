import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/utils/date_helpers.dart';

void main() {
  group('startOfDay', () {
    test('drops the time of day', () {
      expect(
        startOfDay(DateTime(2026, 8, 29, 14, 37, 12)),
        DateTime(2026, 8, 29),
      );
    });
  });

  group('isSameDay', () {
    test('true for two instants on the same calendar day', () {
      expect(
        isSameDay(DateTime(2026, 8, 29, 0, 1), DateTime(2026, 8, 29, 23, 59)),
        isTrue,
      );
    });

    test('false across a day boundary', () {
      expect(
        isSameDay(DateTime(2026, 8, 29, 23, 59), DateTime(2026, 8, 30, 0, 1)),
        isFalse,
      );
    });
  });

  group('startOfWeek', () {
    test('returns Monday 00:00 for a mid-week date', () {
      // 2026-08-29 is a Saturday.
      expect(startOfWeek(DateTime(2026, 8, 29, 18)), DateTime(2026, 8, 24));
    });

    test('returns the same day when already Monday', () {
      expect(startOfWeek(DateTime(2026, 8, 24, 9)), DateTime(2026, 8, 24));
    });

    test('rolls back into the previous month across a month boundary', () {
      // 2026-09-01 is a Tuesday, so Monday falls in August.
      expect(startOfWeek(DateTime(2026, 9, 1)), DateTime(2026, 8, 31));
    });
  });
}
