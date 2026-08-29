import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/session_event.dart';

void main() {
  group('SessionEvent', () {
    test('equal when type, round and cueText match', () {
      const a = SessionEvent(SessionEventType.cue, round: 2, cueText: 'jab');
      const b = SessionEvent(SessionEventType.cue, round: 2, cueText: 'jab');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when any field differs', () {
      const base = SessionEvent(SessionEventType.roundStarted, round: 1);
      expect(
        base,
        isNot(const SessionEvent(SessionEventType.roundStarted, round: 2)),
      );
      expect(
        base,
        isNot(const SessionEvent(SessionEventType.restStarted, round: 1)),
      );
      expect(
        const SessionEvent(SessionEventType.cue, round: 1, cueText: 'jab'),
        isNot(
          const SessionEvent(SessionEventType.cue, round: 1, cueText: 'cross'),
        ),
      );
    });

    test('toString includes the cue text only when set', () {
      const withCue = SessionEvent(
        SessionEventType.cue,
        round: 1,
        cueText: 'jab',
      );
      const withoutCue = SessionEvent(SessionEventType.roundStarted, round: 1);
      expect(withCue.toString(), contains('jab'));
      expect(withoutCue.toString(), isNot(contains('cue:')));
    });
  });
}
