import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/boxing_facts.dart';
import 'package:boxer_os/models/boxing_fact.dart';

void main() {
  test('has exactly 40 facts, each with text and a subject', () {
    expect(boxingFacts.length, 40);
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

  test('no duplicate fact text', () {
    final texts = boxingFacts.map((fact) => fact.text).toSet();

    expect(texts, hasLength(boxingFacts.length));
  });

  group('factFor', () {
    test('is stable for two moments within the same day', () {
      final morning = DateTime(2026, 3, 10, 6);
      final night = DateTime(2026, 3, 10, 23);

      expect(
        factFor(FactSurface.home, morning),
        factFor(FactSurface.home, night),
      );
    });

    test('gives each surface its own fact on the same day', () {
      final day = DateTime(2026, 1, 1);

      expect(
        factFor(FactSurface.home, day) == factFor(FactSurface.progress, day),
        isFalse,
      );
    });

    test('moves on as the day of year advances', () {
      final day = DateTime(2026, 1, 1);
      final nextDay = DateTime(2026, 1, 2);

      expect(
        factFor(FactSurface.home, nextDay) == factFor(FactSurface.home, day),
        isFalse,
      );
    });

    test('the two surfaces never coincide on any day of a leap year', () {
      var day = DateTime(2024);
      final leapYearEnd = DateTime(2025);
      while (day.isBefore(leapYearEnd)) {
        expect(
          factFor(FactSurface.home, day) == factFor(FactSurface.progress, day),
          isFalse,
        );

        day = day.add(const Duration(days: 1));
      }
    });
  });

  group('factAfter', () {
    test('walks the whole list and wraps back to where it started', () {
      final first = factFor(FactSurface.home, DateTime(2026, 1, 1));
      var current = first;
      final seen = <BoxingFact>{first};
      for (var i = 0; i < boxingFacts.length - 1; i++) {
        current = factAfter(current);
        seen.add(current);
      }

      expect(seen, hasLength(boxingFacts.length));
      expect(factAfter(current), first);
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
