import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/models/quote.dart';

void main() {
  test('has exactly 81 quotes, each with text, author and sport', () {
    expect(quotes.length, 81);
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

  test('no duplicate quote text', () {
    final texts = quotes.map((quote) => quote.text).toSet();

    expect(texts, hasLength(quotes.length));
  });

  test('at least 60 percent of quotes are from boxing', () {
    final boxingCount = quotes
        .where(
          (quote) => quote.sport == 'Boxing' || quote.sport == 'Boxing trainer',
        )
        .length;

    expect(boxingCount / quotes.length, greaterThanOrEqualTo(0.6));
  });

  group('quoteFor', () {
    test('is stable for two moments within the same day', () {
      final morning = DateTime(2026, 3, 10, 6);
      final night = DateTime(2026, 3, 10, 23);

      expect(
        quoteFor(QuoteSurface.home, morning),
        quoteFor(QuoteSurface.home, night),
      );
    });

    test('moves on as the day of year advances', () {
      final day = DateTime(2026, 1, 1);
      final nextDay = DateTime(2026, 1, 2);

      expect(
        quoteFor(QuoteSurface.home, day) ==
            quoteFor(QuoteSurface.home, nextDay),
        isFalse,
      );
    });

    test('gives each surface its own quote on the same day', () {
      final day = DateTime(2026, 1, 1);
      final shown = QuoteSurface.values.map((s) => quoteFor(s, day)).toSet();

      expect(shown, hasLength(QuoteSurface.values.length));
    });

    test('always returns a bundled quote', () {
      final wrapped = DateTime(2026, 12, 31);

      expect(quotes.contains(quoteFor(QuoteSurface.reminder, wrapped)), isTrue);
    });

    test('the four surfaces never coincide on any day of a leap year, and each '
        "day's result repeats if asked again", () {
      var day = DateTime(2024);
      final leapYearEnd = DateTime(2025);
      while (day.isBefore(leapYearEnd)) {
        final shown = QuoteSurface.values
            .map((surface) => quoteFor(surface, day))
            .toSet();

        expect(shown, hasLength(QuoteSurface.values.length));
        expect(
          quoteFor(QuoteSurface.home, day),
          quoteFor(QuoteSurface.home, day),
        );

        day = day.add(const Duration(days: 1));
      }
    });
  });

  group('quoteAfter', () {
    test('walks the whole list and wraps back to where it started', () {
      final first = quoteFor(QuoteSurface.home, DateTime(2026, 1, 1));
      var current = first;
      final seen = <Quote>{first};
      for (var i = 0; i < quotes.length - 1; i++) {
        current = quoteAfter(current);
        seen.add(current);
      }

      expect(seen, hasLength(quotes.length));
      expect(quoteAfter(current), first);
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
