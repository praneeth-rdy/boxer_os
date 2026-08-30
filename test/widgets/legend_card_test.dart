import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/legend.dart';
import 'package:boxer_os/widgets/legend_card.dart';

const Legend _legend = Legend(
  id: 'test',
  name: 'Test Boxer',
  nickname: 'The Test',
  years: 'born 1990',
  country: 'Testland',
  division: 'Heavyweight',
  record: '10 wins, 0 losses',
  hook: 'A hook line that describes the boxer for the card preview text.',
  sections: [],
  quoteIndexes: [],
  takeaways: [],
  imageAsset: 'assets/legends/ali.jpg',
  credit: PhotoCredit(
    author: 'Someone',
    license: 'Public domain',
    source: 'https://example.com',
  ),
  gallery: [],
);

// The card is built for a list: it takes the width it is given and grows
// downwards, so the test gives it the same unbounded height a list would.
Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: ListView(children: [child])),
);

void main() {
  testWidgets('shows the country and division eyebrow, name and hook', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(LegendCard(legend: _legend, onTap: () {})));

    expect(find.text('Testland · Heavyweight'), findsOneWidget);
    expect(find.text('Test Boxer'), findsOneWidget);
    expect(find.text(_legend.hook), findsOneWidget);
  });

  testWidgets('tapping the card calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(LegendCard(legend: _legend, onTap: () => tapped = true)),
    );

    await tester.tap(find.byType(LegendCard), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('featured uses a 4:3 aspect ratio', (tester) async {
    await tester.pumpWidget(
      _wrap(LegendCard(legend: _legend, onTap: () {}, featured: true)),
    );

    final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspect.aspectRatio, closeTo(4 / 3, 0.001));
  });

  testWidgets('not featured uses a 1:1 aspect ratio', (tester) async {
    await tester.pumpWidget(_wrap(LegendCard(legend: _legend, onTap: () {})));

    final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspect.aspectRatio, closeTo(1, 0.001));
  });

  testWidgets('the photo is cropped around the legend photoFocus', (
    tester,
  ) async {
    const focused = Legend(
      id: 'test-focus',
      name: 'Test Boxer',
      nickname: 'The Test',
      years: 'born 1990',
      country: 'Testland',
      division: 'Heavyweight',
      record: '10 wins, 0 losses',
      hook: 'A hook line that describes the boxer for the card preview text.',
      sections: [],
      quoteIndexes: [],
      takeaways: [],
      imageAsset: 'assets/legends/ali.jpg',
      credit: PhotoCredit(
        author: 'Someone',
        license: 'Public domain',
        source: 'https://example.com',
      ),
      gallery: [],
      photoFocus: Alignment.center,
    );
    await tester.pumpWidget(_wrap(LegendCard(legend: focused, onTap: () {})));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.alignment, Alignment.center);
  });

  testWidgets('the hook is capped at two lines', (tester) async {
    await tester.pumpWidget(_wrap(LegendCard(legend: _legend, onTap: () {})));

    final hook = tester.widget<Text>(find.text(_legend.hook));
    expect(hook.maxLines, 2);
    expect(hook.overflow, TextOverflow.ellipsis);
  });
}
