import 'package:boxer_os/models/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Difficulty', () {
    test('label reads correctly for each value', () {
      expect(Difficulty.beginner.label, 'Beginner');
      expect(Difficulty.intermediate.label, 'Intermediate');
      expect(Difficulty.advanced.label, 'Advanced');
    });

    test('fromName returns the matching value', () {
      expect(Difficulty.fromName('advanced'), Difficulty.advanced);
      expect(Difficulty.fromName('intermediate'), Difficulty.intermediate);
    });

    test('fromName falls back to beginner when the name is null', () {
      expect(Difficulty.fromName(null), Difficulty.beginner);
    });

    test('fromName falls back to beginner when the name is unknown', () {
      expect(Difficulty.fromName('nope'), Difficulty.beginner);
    });
  });
}
