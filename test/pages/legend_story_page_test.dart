import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/data/quotes.dart';
import 'package:boxer_os/models/legend.dart';
import 'package:boxer_os/pages/legend_story_page.dart';
import 'package:boxer_os/widgets/gallery_strip.dart';
import 'package:boxer_os/widgets/quote_card.dart';

Legend get _ali => legends.firstWhere((legend) => legend.id == 'ali');

Future<void> _pump(
  WidgetTester tester,
  Legend legend, {
  // Tall enough that the whole story lays out without needing a scroll for most assertions.
  Size size = const Size(393, 8000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(home: LegendStoryPage(legend: legend)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the name, hook, every section and the photo credit', (
    tester,
  ) async {
    final legend = _ali;
    await _pump(tester, legend);

    expect(find.text(legend.name), findsWidgets);
    expect(find.text(legend.hook), findsOneWidget);
    for (final section in legend.sections) {
      expect(find.text(section.heading), findsOneWidget);
      expect(find.text(section.body), findsOneWidget);
    }
    expect(
      find.text(
        '${legend.credit.author}. ${legend.credit.license}. Wikimedia Commons.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the facts strip with country, division and record', (
    tester,
  ) async {
    final legend = _ali;
    await _pump(tester, legend);

    expect(find.text(legend.country), findsOneWidget);
    expect(find.text(legend.division), findsOneWidget);
    expect(find.text(legend.record), findsOneWidget);
  });

  testWidgets('shows the takeaways in order, numbered from one', (
    tester,
  ) async {
    final legend = _ali;
    await _pump(tester, legend);

    expect(find.text('WHAT TO TAKE FROM IT'), findsOneWidget);
    expect(legend.takeaways.length, 3);
    for (final takeaway in legend.takeaways) {
      expect(find.text(takeaway), findsOneWidget);
    }
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets("shows the legend's pull quotes between sections", (
    tester,
  ) async {
    final legend = _ali;
    await _pump(tester, legend);

    expect(find.byType(QuoteCard), findsNWidgets(legend.quoteIndexes.length));
    for (final index in legend.quoteIndexes) {
      expect(find.text(quotes[index].text), findsOneWidget);
    }
  });

  testWidgets('scrolling the hero out of view reveals the name in the app bar', (
    tester,
  ) async {
    final legend = _ali;
    // A real phone-sized viewport, so the story is actually taller than the screen.
    await _pump(tester, legend, size: const Size(393, 873));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 1);
  });

  testWidgets('the hero title stays hidden while the photo is expanded', (
    tester,
  ) async {
    final legend = _ali;
    await _pump(tester, legend);

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 0);
  });

  testWidgets('tapping the photo credit does not throw', (tester) async {
    final legend = _ali;
    await _pump(tester, legend);

    await tester.tap(
      find.textContaining('Wikimedia Commons.'),
      warnIfMissed: false,
    );
    await tester.pump();
  });

  testWidgets('lays out every legend with no overflow on a 393x873 viewport', (
    tester,
  ) async {
    for (final legend in legends) {
      await _pump(tester, legend, size: const Size(393, 873));

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'shows the archive gallery strip with all of the legend\'s photos',
    (tester) async {
      final legend = _ali;
      await _pump(tester, legend);

      expect(find.text('FROM THE ARCHIVE'), findsOneWidget);
      expect(find.byType(GalleryStrip), findsOneWidget);
      final strip = tester.widget<GalleryStrip>(find.byType(GalleryStrip));
      expect(strip.photos, legend.gallery);
    },
  );
}
