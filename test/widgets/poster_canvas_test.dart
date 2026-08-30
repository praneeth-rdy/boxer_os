import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/posters.dart';
import 'package:boxer_os/models/poster.dart';
import 'package:boxer_os/widgets/poster_canvas.dart';

const Size _wallpaperSize = Size(360, 780);

Poster _posterOf(PosterKind kind) =>
    posters().firstWhere((poster) => poster.kind == kind);

Widget _wrap(Poster poster, {Key? key}) => MaterialApp(
  home: Scaffold(
    body: RepaintBoundary(
      key: key,
      child: PosterCanvas(poster: poster, size: _wallpaperSize),
    ),
  ),
);

/// Taller than the wallpaper's own 780, so the Scaffold body never clamps
/// the canvas smaller than the size it was given.
Future<void> _pumpPoster(WidgetTester tester, Poster poster, {Key? key}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(poster, key: key));
  await tester.pump();
}

/// The width and height baked into a PNG's IHDR chunk, big-endian at bytes
/// 16 and 20.
(int, int) _pngSize(Uint8List bytes) {
  final data = bytes.buffer.asByteData(bytes.offsetInBytes, bytes.length);
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  for (final kind in PosterKind.values) {
    testWidgets('renders a ${kind.name} poster at 360x780 without overflow', (
      tester,
    ) async {
      await _pumpPoster(tester, _posterOf(kind));

      expect(tester.takeException(), isNull);
    });
  }

  for (var variant = 0; variant < taglineLines.length; variant++) {
    testWidgets('renders tagline variant $variant without overflow', (
      tester,
    ) async {
      final poster = posters().firstWhere(
        (poster) =>
            poster.kind == PosterKind.tagline && poster.variant == variant,
      );

      await _pumpPoster(tester, poster);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a moment poster shows the legend name, caption and credit', (
    tester,
  ) async {
    final poster = _posterOf(PosterKind.moment);
    final gallery = poster.gallery!;

    await _pumpPoster(tester, poster);

    expect(find.text(poster.legend!.name.toUpperCase()), findsOneWidget);
    expect(find.text(gallery.caption), findsOneWidget);
    expect(
      find.text('${gallery.credit.author}, ${gallery.credit.license}'),
      findsOneWidget,
    );
  });

  testWidgets('an inspiration poster shows the line, caption and credit', (
    tester,
  ) async {
    final poster = _posterOf(PosterKind.inspiration);
    final photo = poster.photo!;

    await _pumpPoster(tester, poster);

    expect(find.text(photo.line), findsOneWidget);
    expect(find.text(photo.caption), findsOneWidget);
    expect(
      find.text('${photo.credit.author}, ${photo.credit.license}'),
      findsOneWidget,
    );
  });

  testWidgets('RepaintBoundary.toImage captures the poster at its full size', (
    tester,
  ) async {
    final key = GlobalKey();
    await _pumpPoster(tester, _posterOf(PosterKind.quote), key: key);

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      expect(data, isNotNull);
      final bytes = data!.buffer.asUint8List();
      expect(bytes.length, greaterThan(0));
      expect(_pngSize(bytes), (
        _wallpaperSize.width.toInt(),
        _wallpaperSize.height.toInt(),
      ));
    });
  });
}
