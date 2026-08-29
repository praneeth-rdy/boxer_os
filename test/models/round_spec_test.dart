import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/round_cue.dart';
import 'package:boxer_os/models/round_spec.dart';

void main() {
  group('RoundCue', () {
    test('toJson/fromJson round-trips at and text', () {
      const cue = RoundCue(atSecond: 12, text: '1-2, slip');

      final restored = RoundCue.fromJson(cue.toJson());

      expect(restored, cue);
      expect(cue.toJson(), {'at': 12, 'text': '1-2, slip'});
    });

    test('equality compares atSecond and text', () {
      expect(
        const RoundCue(atSecond: 5, text: 'jab'),
        const RoundCue(atSecond: 5, text: 'jab'),
      );
      expect(
        const RoundCue(atSecond: 5, text: 'jab'),
        isNot(const RoundCue(atSecond: 6, text: 'jab')),
      );
      expect(
        const RoundCue(atSecond: 5, text: 'jab').hashCode,
        const RoundCue(atSecond: 5, text: 'jab').hashCode,
      );
    });
  });

  group('RoundSpec', () {
    test('toJson/fromJson round-trips work, rest, focus and cues', () {
      const spec = RoundSpec(
        workSeconds: 120,
        restSeconds: 60,
        focus: 'Jab only',
        cues: [
          RoundCue(atSecond: 4, text: '1'),
          RoundCue(atSecond: 30, text: '1-1'),
        ],
      );

      final restored = RoundSpec.fromJson(spec.toJson());

      expect(restored, spec);
      expect(restored.cues, spec.cues);
    });

    test('fromJson defaults missing fields', () {
      final spec = RoundSpec.fromJson(const {});

      expect(spec.workSeconds, 0);
      expect(spec.restSeconds, 0);
      expect(spec.focus, '');
      expect(spec.cues, isEmpty);
    });

    test('equality compares all four fields', () {
      const a = RoundSpec(workSeconds: 60, restSeconds: 30, focus: 'x');
      const b = RoundSpec(workSeconds: 60, restSeconds: 30, focus: 'x');
      const c = RoundSpec(workSeconds: 60, restSeconds: 31, focus: 'x');

      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
    });
  });
}
