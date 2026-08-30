import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/legend.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/utils/external_links.dart' as external_links;
import 'package:boxer_os/widgets/gallery_strip.dart';

const List<GalleryPhoto> _photos = [
  GalleryPhoto(
    asset: 'assets/legends/gallery/ali_1.jpg',
    caption: 'Backing Sonny Liston into the ropes, Miami Beach.',
    credit: PhotoCredit(
      author: 'Associated Press',
      license: 'Public domain',
      source: 'https://example.com/ali_1',
    ),
  ),
  GalleryPhoto(
    asset: 'assets/legends/gallery/ali_2.jpg',
    caption: 'In Amsterdam, 1966.',
    credit: PhotoCredit(
      author: 'Anefo',
      license: 'CC0',
      source: 'https://example.com/ali_2',
    ),
  ),
];

Future<void> _pump(WidgetTester tester, List<GalleryPhoto> photos) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(height: 400, child: GalleryStrip(photos: photos)),
      ),
    ),
  );
}

void main() {
  final originalLauncher = external_links.launcher;

  tearDown(() {
    external_links.launcher = originalLauncher;
  });

  testWidgets('shows a caption and an author, license credit line per photo', (
    tester,
  ) async {
    await _pump(tester, _photos);

    for (final photo in _photos) {
      expect(find.text(photo.caption), findsOneWidget);
      expect(
        find.text('${photo.credit.author}, ${photo.credit.license}'),
        findsOneWidget,
      );
    }
  });

  testWidgets('renders one image per photo with no exceptions', (tester) async {
    await _pump(tester, _photos);

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNWidgets(_photos.length));
  });

  testWidgets('tapping a photo opens a full screen viewer with its caption', (
    tester,
  ) async {
    await _pump(tester, _photos);

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text(_photos.first.caption), findsWidgets);
  });

  testWidgets('the viewer closes on tap outside', (tester) async {
    await _pump(tester, _photos);

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Barrier dismiss: tap a corner outside the dialog content.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('tapping the credit line opens its photo source', (tester) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester, _photos);

    await tester.tap(
      find.text(
        '${_photos.first.credit.author}, ${_photos.first.credit.license}',
      ),
    );
    await tester.pumpAndSettle();

    expect(requested, [_photos.first.credit.source]);
  });

  testWidgets('insets the first photo by the page padding, not the strip', (
    tester,
  ) async {
    const viewportWidth = 393.0;
    tester.view.physicalSize = const Size(viewportWidth, 873);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(tester, _photos);

    final list = tester.widget<ListView>(find.byType(ListView));
    expect((list.padding! as EdgeInsets).left, AppTheme.spaceLg);
    expect((list.padding! as EdgeInsets).right, AppTheme.spaceLg);
    expect(tester.getSize(find.byType(GalleryStrip)).width, viewportWidth);
  });
}
