import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/quotes.dart';

void main() {
  test('has exactly 30 quotes, each with text, author and sport', () {
    expect(quotes.length, 30);
    for (final quote in quotes) {
      expect(quote.text, isNotEmpty);
      expect(quote.author, isNotEmpty);
      expect(quote.sport, isNotEmpty);
    }
  });

  test('no quote text contains an em-dash', () {
    for (final quote in quotes) {
      expect(quote.text.contains('—'), isFalse);
    }
  });

  group('quoteOfTheDay', () {
    test('is stable for two moments within the same day', () {
      final morning = DateTime(2026, 3, 10, 6);
      final night = DateTime(2026, 3, 10, 23);

      expect(quoteOfTheDay(morning), quoteOfTheDay(night));
    });

    test('cycles through the list as the day of year advances', () {
      final day = DateTime(2026, 1, 1);
      final nextDay = DateTime(2026, 1, 2);

      expect(quoteOfTheDay(day), quotes[0]);
      expect(quoteOfTheDay(nextDay), quotes[1]);
    });

    test('wraps around once the day of year exceeds the list length', () {
      final wrapped = DateTime(2026, 1, 31);

      expect(quoteOfTheDay(wrapped), quotes[30 % quotes.length]);
    });
  });

  group('quoteForSession', () {
    test('returns the same quote for the same record id', () {
      expect(quoteForSession('abc'), quoteForSession('abc'));
    });

    test('picks an index within range for a given id', () {
      final quote = quoteForSession('abc');

      expect(quotes.contains(quote), isTrue);
    });
  });
}
