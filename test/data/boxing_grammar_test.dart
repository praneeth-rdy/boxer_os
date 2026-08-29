import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_grammar.dart';

void main() {
  group('isValidCombination endings', () {
    test('the high-low jab 1-1b is valid', () {
      expect(isValidCombination(['1', '1b']), isTrue);
    });

    test('a longer chain may not end on the body jab', () {
      expect(isValidCombination(['1', '2', '1b']), isFalse);
    });
  });
}
