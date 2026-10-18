import 'package:boxer_os/models/round_cue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoundCue JSON round trip', () {
    test('toJson emits at and text keys', () {
      const cue = RoundCue(atSecond: 45, text: 'Double jab');

      expect(cue.toJson(), {'at': 45, 'text': 'Double jab'});
    });

    test('fromJson reads at and text and round-trips', () {
      final cue = RoundCue.fromJson(const {'at': 30, 'text': 'Slip left'});

      expect(cue.atSecond, 30);
      expect(cue.text, 'Slip left');
      expect(RoundCue.fromJson(cue.toJson()), cue);
    });

    test('fromJson defaults a missing at to 0 and a missing text to empty', () {
      final cue = RoundCue.fromJson(const {});

      expect(cue.atSecond, 0);
      expect(cue.text, '');
    });
  });

  group('RoundCue equality', () {
    test('two cues with the same fields are equal and share a hash code', () {
      const a = RoundCue(atSecond: 10, text: 'Jab');
      const b = RoundCue(atSecond: 10, text: 'Jab');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('cues with a different field are not equal', () {
      const a = RoundCue(atSecond: 10, text: 'Jab');
      const b = RoundCue(atSecond: 11, text: 'Jab');

      expect(a == b, false);
    });
  });
}
