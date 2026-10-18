import 'package:boxer_os/models/poster.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PosterKind.label', () {
    test('maps each kind to the gallery label the UI shows', () {
      expect(PosterKind.tagline.label, 'Taglines');
      expect(PosterKind.legend.label, 'Legends');
      expect(PosterKind.moment.label, 'Moments');
      expect(PosterKind.inspiration.label, 'Inspiration');
      expect(PosterKind.quote.label, 'Quotes');
    });
  });
}
