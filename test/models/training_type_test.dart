import 'package:boxer_os/models/training_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingType.fromName', () {
    test('returns the matching value for a valid name', () {
      expect(TrainingType.fromName('heavyBag'), TrainingType.heavyBag);
      expect(TrainingType.fromName('sparring'), TrainingType.sparring);
    });

    test('falls back to custom when the name is null', () {
      expect(TrainingType.fromName(null), TrainingType.custom);
    });

    test('falls back to custom when the name is unknown', () {
      expect(TrainingType.fromName('not_a_real_type'), TrainingType.custom);
    });
  });
}
