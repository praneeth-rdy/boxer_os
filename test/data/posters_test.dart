import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/data/wall_photos.dart';
import 'package:boxer_os/models/poster.dart';

int get _momentCount =>
    legends.fold(0, (total, legend) => total + legend.gallery.length);

void main() {
  group('posters', () {
    test('builds 148 posters total', () {
      final all = posters();

      expect(
        all.length,
        4 + legends.length + _momentCount + wallPhotos.length + quotes.length,
      );
      expect(all.length, 148);
    });

    test('holds the kind counts from the spec', () {
      final all = posters();
      final byKind = <PosterKind, int>{
        for (final kind in PosterKind.values)
          kind: all.where((poster) => poster.kind == kind).length,
      };

      expect(byKind[PosterKind.tagline], 4);
      expect(byKind[PosterKind.legend], 12);
      expect(byKind[PosterKind.moment], 34);
      expect(byKind[PosterKind.inspiration], 14);
      expect(byKind[PosterKind.quote], 84);
    });

    test(
      'orders taglines, then legends, then moments, then inspiration, then quotes',
      () {
        final all = posters();
        final kinds = all.map((poster) => poster.kind).toList();

        final firstLegend = kinds.indexOf(PosterKind.legend);
        final firstMoment = kinds.indexOf(PosterKind.moment);
        final firstInspiration = kinds.indexOf(PosterKind.inspiration);
        final firstQuote = kinds.indexOf(PosterKind.quote);

        expect(kinds.take(4), everyElement(PosterKind.tagline));
        expect(firstLegend, 4);
        expect(
          kinds.sublist(firstLegend, firstMoment),
          everyElement(PosterKind.legend),
        );
        expect(
          kinds.sublist(firstMoment, firstInspiration),
          everyElement(PosterKind.moment),
        );
        expect(
          kinds.sublist(firstInspiration, firstQuote),
          everyElement(PosterKind.inspiration),
        );
        expect(kinds.sublist(firstQuote), everyElement(PosterKind.quote));
      },
    );

    test('builds one poster per legend, in legend order', () {
      final all = posters();
      final legendPosters = all.where(
        (poster) => poster.kind == PosterKind.legend,
      );

      expect(legendPosters.length, legends.length);
      expect(
        legendPosters.map((poster) => poster.legend?.id),
        legends.map((legend) => legend.id),
      );
    });

    test('builds one poster per quote, in quote order', () {
      final all = posters();
      final quotePosters = all.where(
        (poster) => poster.kind == PosterKind.quote,
      );

      expect(quotePosters.length, quotes.length);
      expect(
        quotePosters.map((poster) => poster.quote?.text),
        quotes.map((quote) => quote.text),
      );
    });

    test('builds one moment poster per gallery photo, in legends order', () {
      final all = posters();
      final momentPosters = all
          .where((poster) => poster.kind == PosterKind.moment)
          .toList();

      final expectedIds = <String>[
        for (final legend in legends)
          for (var index = 0; index < legend.gallery.length; index++)
            'moment_${legend.id}_${index + 1}',
      ];

      expect(momentPosters.map((poster) => poster.id), expectedIds);
      expect(
        momentPosters.every(
          (poster) => poster.legend != null && poster.gallery != null,
        ),
        isTrue,
      );
    });

    test('every moment credit contains the photo author and license', () {
      final all = posters();
      final momentPosters = all.where(
        (poster) => poster.kind == PosterKind.moment,
      );

      for (final poster in momentPosters) {
        final credit = poster.gallery!.credit;

        expect(credit.author, isNotEmpty, reason: poster.id);
        expect(credit.license, isNotEmpty, reason: poster.id);
      }
    });

    test('builds one inspiration poster per wall photo, in order', () {
      final all = posters();
      final inspirationPosters = all
          .where((poster) => poster.kind == PosterKind.inspiration)
          .toList();

      expect(
        inspirationPosters.map((poster) => poster.id),
        wallPhotos.map((photo) => 'wall_${photo.id}'),
      );
      expect(
        inspirationPosters.map((poster) => poster.photo?.id),
        wallPhotos.map((photo) => photo.id),
      );
    });

    test('every inspiration credit contains the photo author and license', () {
      final all = posters();
      final inspirationPosters = all.where(
        (poster) => poster.kind == PosterKind.inspiration,
      );

      for (final poster in inspirationPosters) {
        final credit = poster.photo!.credit;

        expect(credit.author, isNotEmpty, reason: poster.id);
        expect(credit.license, isNotEmpty, reason: poster.id);
      }
    });

    test('tagline posters cover variants 0 to 3 with matching titles', () {
      final all = posters();
      final taglinePosters = all
          .where((poster) => poster.kind == PosterKind.tagline)
          .toList();

      expect(taglinePosters.map((poster) => poster.variant), [0, 1, 2, 3]);
      expect(taglinePosters.every((poster) => poster.title.isNotEmpty), isTrue);
    });
  });

  group('posterCredit', () {
    test(
      "contains the photographer's name and the licence for every legend",
      () {
        // Pacquiao's poster credits his archive photo, not his portrait;
        // that pairing is covered by its own test below.
        for (final legend in legends.where(
          (legend) => legend.id != 'pacquiao',
        )) {
          final credit = posterCredit(legend);

          expect(credit, contains(legend.credit.author.split(' ').first));
          expect(credit, contains(legend.credit.license));
        }
      },
    );

    test(
      "uses the archive photo's credit for Pacquiao, not the portrait's",
      () {
        final pacquiao = legends.firstWhere(
          (legend) => legend.id == 'pacquiao',
        );
        final archiveCredit = pacquiao.gallery.first.credit;

        final credit = posterCredit(pacquiao);

        expect(credit, contains(archiveCredit.author));
        expect(credit, contains(archiveCredit.license));
      },
    );

    test('uses the portrait credit for a legend with no archive override', () {
      final ali = legends.firstWhere((legend) => legend.id == 'ali');

      final credit = posterCredit(ali);

      expect(credit, contains(ali.credit.author));
      expect(credit, contains(ali.credit.license));
    });
  });

  group('posterPhotoAsset and posterPhotoFocus', () {
    test("Pacquiao's poster uses his first gallery photo, centred", () {
      final pacquiao = legends.firstWhere((legend) => legend.id == 'pacquiao');

      expect(posterPhotoAsset(pacquiao), pacquiao.gallery.first.asset);
      expect(posterPhotoFocus(pacquiao), Alignment.center);
    });

    test(
      "a legend with no archive override uses its own portrait and focus",
      () {
        final ali = legends.firstWhere((legend) => legend.id == 'ali');

        expect(posterPhotoAsset(ali), ali.imageAsset);
        expect(posterPhotoFocus(ali), ali.photoFocus);
      },
    );
  });
}
