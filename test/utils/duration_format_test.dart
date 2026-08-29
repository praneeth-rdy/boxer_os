import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/utils/duration_format.dart';

void main() {
  group('formatClock', () {
    test('pads seconds under 10', () {
      expect(formatClock(9), '0:09');
    });

    test('formats minutes and seconds', () {
      expect(formatClock(185), '3:05');
    });

    test('formats double digit minutes', () {
      expect(formatClock(725), '12:05');
    });

    test('formats zero as 0:00', () {
      expect(formatClock(0), '0:00');
    });

    test('clamps negative seconds to zero', () {
      expect(formatClock(-5), '0:00');
    });
  });

  group('formatMinutes', () {
    test('shows 1 min for anything under 90 seconds', () {
      expect(formatMinutes(0), '1 min');
      expect(formatMinutes(89), '1 min');
    });

    test('rounds to the nearest minute above 90 seconds', () {
      expect(formatMinutes(1210), '20 min');
    });

    test('rounds down when under the half minute mark', () {
      expect(formatMinutes(95), '2 min');
    });
  });
}
