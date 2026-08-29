import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/combo_tag.dart';

void main() {
  group('label', () {
    test('offense labels as Offense', () {
      expect(ComboTag.offense.label, 'Offense');
    });

    test('counter labels as Counter', () {
      expect(ComboTag.counter.label, 'Counter');
    });

    test('body labels as Body', () {
      expect(ComboTag.body.label, 'Body');
    });

    test('defense labels as Defense', () {
      expect(ComboTag.defense.label, 'Defense');
    });

    test('movement labels as Movement', () {
      expect(ComboTag.movement.label, 'Movement');
    });
  });

  group('fromName', () {
    test('returns the matching tag for a known name', () {
      expect(ComboTag.fromName('counter'), ComboTag.counter);
      expect(ComboTag.fromName('body'), ComboTag.body);
      expect(ComboTag.fromName('defense'), ComboTag.defense);
      expect(ComboTag.fromName('movement'), ComboTag.movement);
      expect(ComboTag.fromName('offense'), ComboTag.offense);
    });

    test('falls back to offense for an unknown name', () {
      expect(ComboTag.fromName('nope'), ComboTag.offense);
    });

    test('falls back to offense for a null name', () {
      expect(ComboTag.fromName(null), ComboTag.offense);
    });
  });
}
