import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data/posters.dart';
import '../models/poster.dart';
import 'poster_canvas.dart';

/// Paints one poster at a time at the device's size so it can be captured;
/// it must stay in the tree and painting, because an offstage box never paints.
class PosterRenderer extends StatefulWidget {
  const PosterRenderer({super.key});

  @override
  PosterRendererState createState() => PosterRendererState();
}

class PosterRendererState extends State<PosterRenderer> {
  final GlobalKey _boundaryKey = GlobalKey();
  Poster? _poster;

  /// Paints [poster] and returns it as PNG bytes at the device pixel ratio.
  Future<Uint8List> render(Poster poster) async {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    await _precachePhoto(poster);
    if (!mounted) {
      throw Exception('The poster renderer left the tree');
    }
    setState(() => _poster = poster);
    await WidgetsBinding.instance.endOfFrame;
    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw Exception('The poster renderer is not painting');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      throw Exception('Could not encode the poster');
    }
    return bytes.buffer.asUint8List();
  }

  /// A photo poster captured before its image decodes would come out empty.
  Future<void> _precachePhoto(Poster poster) async {
    final legend = poster.legend;
    final asset = switch (poster.kind) {
      PosterKind.legend when legend != null => posterPhotoAsset(legend),
      PosterKind.moment => poster.gallery?.asset,
      PosterKind.inspiration => poster.photo?.asset,
      _ => null,
    };
    if (asset == null) {
      return;
    }
    await precacheImage(
      AssetImage(asset),
      context,
      // A missing photo is left to the canvas's own error builder.
      onError: (error, stack) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final poster = _poster;
    return SizedBox.fromSize(
      size: size,
      child: RepaintBoundary(
        key: _boundaryKey,
        child: poster == null
            ? const SizedBox.shrink()
            : PosterCanvas(poster: poster, size: size),
      ),
    );
  }
}
