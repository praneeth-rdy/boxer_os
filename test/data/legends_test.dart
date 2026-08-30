import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/models/legend.dart';

/// Legends whose own quotes exist in the quote library, mapped to the name
/// (or name prefix) a referenced quote's author must start with.
const Map<String, String> _ownQuoteAuthor = {
  'ali': 'Muhammad Ali',
  'tyson': 'Mike Tyson',
  'frazier': 'Joe Frazier',
  'foreman': 'George Foreman',
  'robinson': 'Sugar Ray Robinson',
  'louis': 'Joe Louis',
  'pacquiao': 'Manny Pacquiao',
  'mayweather': 'Floyd Mayweather',
  'kom': 'Mary Kom',
};

/// Every string field on [legend], flattened for the em-dash / en-dash sweep.
List<String> _allStrings(Legend legend) {
  final strings = <String>[
    legend.id,
    legend.name,
    legend.nickname,
    legend.years,
    legend.country,
    legend.division,
    legend.record,
    legend.hook,
    legend.imageAsset,
    legend.credit.author,
    legend.credit.license,
    legend.credit.source,
  ];
  for (final section in legend.sections) {
    strings.add(section.heading);
    strings.add(section.body);
  }
  strings.addAll(legend.takeaways);
  return strings;
}

void main() {
  group('legends', () {
    test('bundles exactly twelve legends with unique ids', () {
      expect(legends.length, 12);
      final ids = legends.map((legend) => legend.id).toSet();
      expect(ids.length, 12);
    });

    test('every legend has 4 sections and 3 takeaways', () {
      for (final legend in legends) {
        expect(legend.sections.length, 4, reason: legend.id);
        expect(legend.takeaways.length, 3, reason: legend.id);
      }
    });

    test('every legend has 2 or 3 quote indexes within range', () {
      for (final legend in legends) {
        expect(legend.quoteIndexes.length, anyOf(2, 3), reason: legend.id);
        for (final index in legend.quoteIndexes) {
          expect(index, greaterThanOrEqualTo(0), reason: legend.id);
          expect(index, lessThan(quotes.length), reason: legend.id);
        }
      }
    });

    test(
      'legends whose own quotes exist reference at least one of their own',
      () {
        _ownQuoteAuthor.forEach((id, expectedAuthor) {
          final legend = findLegend(id);
          expect(legend, isNotNull, reason: id);
          final authors = legend!.quoteIndexes
              .map((index) => quotes[index].author)
              .toList();
          expect(
            authors.any((author) => author.startsWith(expectedAuthor)),
            isTrue,
            reason: '$id quoteIndexes reference $authors',
          );
        });
      },
    );

    test('every section body is between 140 and 700 characters', () {
      for (final legend in legends) {
        for (final section in legend.sections) {
          expect(
            section.body.length,
            inInclusiveRange(140, 700),
            reason: '${legend.id} / ${section.heading}',
          );
        }
      }
    });

    test('no em-dash or en-dash appears in any legend string', () {
      for (final legend in legends) {
        for (final value in _allStrings(legend)) {
          expect(value.contains('—'), isFalse, reason: legend.id);
          expect(value.contains('–'), isFalse, reason: legend.id);
        }
      }
    });

    test('every credit has a non-empty author, license and source', () {
      for (final legend in legends) {
        expect(legend.credit.author, isNotEmpty, reason: legend.id);
        expect(legend.credit.license, isNotEmpty, reason: legend.id);
        expect(legend.credit.source, isNotEmpty, reason: legend.id);
      }
    });

    test('every imageAsset file exists on disk', () {
      for (final legend in legends) {
        expect(
          File(legend.imageAsset).existsSync(),
          isTrue,
          reason: legend.imageAsset,
        );
      }
    });

    test('pubspec.yaml declares the assets/legends/ folder', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('assets/legends/'), isTrue);
    });

    test('findLegend returns the matching legend or null', () {
      expect(findLegend('ali')?.name, 'Muhammad Ali');
      expect(findLegend('not-a-real-id'), isNull);
    });

    test('legendOfTheWeek covers all twelve legends across a year', () {
      final seen = <String>{};
      var day = DateTime(2026, 1, 1);
      while (day.year == 2026) {
        seen.add(legendOfTheWeek(day).id);
        day = day.add(const Duration(days: 1));
      }
      expect(seen.length, 12);
    });

    test('legendOfTheWeek is stable within the same week', () {
      final start = legendOfTheWeek(DateTime(2026, 1, 2));
      final end = legendOfTheWeek(DateTime(2026, 1, 7));
      expect(start.id, end.id);
    });
  });
}
