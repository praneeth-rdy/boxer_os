import 'package:boxer_os/models/reaction_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactionFormat.fromName', () {
    test('returns the matching value for a valid name', () {
      expect(ReactionFormat.fromName('endurance'), ReactionFormat.endurance);
      expect(ReactionFormat.fromName('standard'), ReactionFormat.standard);
    });

    test('falls back to standard when the name is null', () {
      expect(ReactionFormat.fromName(null), ReactionFormat.standard);
    });

    test('falls back to standard when the name is unknown', () {
      expect(
        ReactionFormat.fromName('not_a_real_format'),
        ReactionFormat.standard,
      );
    });
  });
}
