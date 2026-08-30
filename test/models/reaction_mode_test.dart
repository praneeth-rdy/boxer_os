import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_mode.dart';

void main() {
  group('ReactionMode', () {
    test('isBoxing is true for defense, go / no-go and sequence', () {
      expect(ReactionMode.defense.isBoxing, isTrue);
      expect(ReactionMode.goNoGo.isBoxing, isTrue);
      expect(ReactionMode.sequence.isBoxing, isTrue);
    });

    test(
      'isBoxing is false for tap, direction, peripheral, colour and sound',
      () {
        expect(ReactionMode.tap.isBoxing, isFalse);
        expect(ReactionMode.direction.isBoxing, isFalse);
        expect(ReactionMode.peripheral.isBoxing, isFalse);
        expect(ReactionMode.colour.isBoxing, isFalse);
        expect(ReactionMode.sound.isBoxing, isFalse);
      },
    );

    test('every mode has a non-empty label and description', () {
      for (final mode in ReactionMode.values) {
        expect(mode.label, isNotEmpty);
        expect(mode.description, isNotEmpty);
      }
    });

    test('fromName round-trips every mode by its enum name', () {
      for (final mode in ReactionMode.values) {
        expect(ReactionMode.fromName(mode.name), mode);
      }
    });

    test('fromName falls back to tap for a missing or unknown name', () {
      expect(ReactionMode.fromName(null), ReactionMode.tap);
      expect(ReactionMode.fromName('nope'), ReactionMode.tap);
    });
  });
}
