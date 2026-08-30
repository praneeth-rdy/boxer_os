import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_vocabulary.dart';

void main() {
  test('movementTokens includes the footwork expansion tokens', () {
    expect(movementTokens, containsAll(['pendulum', 'cut left', 'cut right']));
  });

  test('isMovement is true for the new movement tokens', () {
    expect(isMovement('pendulum'), isTrue);
    expect(isMovement('cut left'), isTrue);
    expect(isMovement('cut right'), isTrue);
  });

  test('isMovement is false for a punch', () {
    expect(isMovement('1'), isFalse);
  });
}
