import 'package:boxer_os/models/stance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stance', () {
    test('label reads correctly for each value', () {
      expect(Stance.orthodox.label, 'Orthodox');
      expect(Stance.southpaw.label, 'Southpaw');
    });

    test('fromName returns the matching value', () {
      expect(Stance.fromName('southpaw'), Stance.southpaw);
      expect(Stance.fromName('orthodox'), Stance.orthodox);
    });

    test('fromName falls back to orthodox when the name is null', () {
      expect(Stance.fromName(null), Stance.orthodox);
    });

    test('fromName falls back to orthodox when the name is unknown', () {
      expect(Stance.fromName('nope'), Stance.orthodox);
    });
  });
}
