import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/reaction_colour.dart';
import 'package:boxer_os/theme/app_theme.dart';

void main() {
  group('ReactionColour', () {
    test('every colour has a distinct label and swatch', () {
      final labels = ReactionColour.values.map((colour) => colour.label);
      final swatches = ReactionColour.values.map((colour) => colour.swatch);
      expect(labels.toSet(), hasLength(ReactionColour.values.length));
      expect(swatches.toSet(), hasLength(ReactionColour.values.length));
    });

    test('onSwatch keeps chalk text on the dark red and mint fills', () {
      expect(ReactionColour.red.onSwatch, AppTheme.chalk);
      expect(ReactionColour.mint.onSwatch, AppTheme.chalk);
    });

    test('onSwatch keeps ink text on the light amber and chalk fills', () {
      expect(ReactionColour.amber.onSwatch, AppTheme.ink);
      expect(ReactionColour.chalk.onSwatch, AppTheme.ink);
    });
  });
}
