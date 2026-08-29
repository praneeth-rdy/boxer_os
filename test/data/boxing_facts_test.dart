import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_facts.dart';

void main() {
  test('has exactly 24 facts, each with text and a subject', () {
    expect(boxingFacts.length, 24);
    for (final fact in boxingFacts) {
      expect(fact.text, isNotEmpty);
      expect(fact.subject, isNotEmpty);
    }
  });

  test('no fact text contains an em-dash', () {
    for (final fact in boxingFacts) {
      expect(fact.text.contains('—'), isFalse);
    }
  });

  test('the first fact is about Rocky Marciano', () {
    expect(boxingFacts.first.subject, 'Rocky Marciano');
  });

  group('factOfTheDay', () {
    test('is stable for two moments within the same day', () {
      final morning = DateTime(2026, 3, 10, 6);
      final night = DateTime(2026, 3, 10, 23);

      expect(factOfTheDay(morning), factOfTheDay(night));
    });

    test('is offset from quoteOfTheDay so both do not change together', () {
      final day = DateTime(2026, 1, 1);

      expect(factOfTheDay(day), boxingFacts[7 % boxingFacts.length]);
    });

    test('cycles through the list as the day of year advances', () {
      final day = DateTime(2026, 1, 1);
      final nextDay = DateTime(2026, 1, 2);

      expect(factOfTheDay(nextDay) == factOfTheDay(day), isFalse);
    });
  });

  group('factForSession', () {
    test('returns the same fact for the same record id', () {
      expect(factForSession('abc'), factForSession('abc'));
    });

    test('picks a fact within the bundled list', () {
      final fact = factForSession('abc');

      expect(boxingFacts.contains(fact), isTrue);
    });
  });
}
