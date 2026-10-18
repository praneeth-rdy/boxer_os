import 'package:boxer_os/models/incoming_punch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IncomingPunch.label', () {
    test('maps each punch to its own upper case label', () {
      expect(IncomingPunch.jab.label, 'JAB');
      expect(IncomingPunch.cross.label, 'CROSS');
      expect(IncomingPunch.leadHook.label, 'LEAD HOOK');
      expect(IncomingPunch.rearHook.label, 'REAR HOOK');
      expect(IncomingPunch.body.label, 'BODY');
    });

    test('every punch maps to a distinct label', () {
      final labels = IncomingPunch.values.map((p) => p.label).toSet();

      expect(labels.length, IncomingPunch.values.length);
    });
  });
}
