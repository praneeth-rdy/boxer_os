import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../models/poster.dart';
import '../services/wallpaper_service.dart';
import '../theme/app_theme.dart';
import '../widgets/phone_preview.dart';
import '../widgets/pill_button.dart';
import '../widgets/poster_canvas.dart';

const double _previewFraction = 0.7;
const String _setMessage = 'Wallpaper set';
const String _failedMessage = 'Could not set wallpaper';

/// One poster full size, with the three ways to hang it.
class PosterPage extends StatefulWidget {
  const PosterPage({required this.poster, super.key});

  final Poster poster;

  @override
  State<PosterPage> createState() => _PosterPageState();
}

class _PosterPageState extends State<PosterPage> {
  final GlobalKey _posterKey = GlobalKey();
  WallpaperTarget? _pending;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          Center(
            child: SizedBox(
              width: screen.width * _previewFraction,
              child: PhonePreview(
                child: RepaintBoundary(
                  key: _posterKey,
                  child: PosterCanvas(poster: widget.poster, size: screen),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),
          _SetButton(
            label: 'Set as home screen',
            target: WallpaperTarget.home,
            pending: _pending,
            onPressed: _setWallpaper,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _SetButton(
            label: 'Set as lock screen',
            target: WallpaperTarget.lock,
            style: PillStyle.outlined,
            pending: _pending,
            onPressed: _setWallpaper,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _SetButton(
            label: 'Set both',
            target: WallpaperTarget.both,
            style: PillStyle.outlined,
            pending: _pending,
            onPressed: _setWallpaper,
          ),
        ],
      ),
    );
  }

  Future<void> _setWallpaper(WallpaperTarget target) async {
    final wallpaper = context.read<WallpaperService>();
    final messenger = ScaffoldMessenger.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    setState(() => _pending = target);
    final png = await _renderPoster(pixelRatio);
    final isSet = png != null && await wallpaper.set(png, target);
    if (!mounted) {
      return;
    }
    setState(() => _pending = null);
    messenger.showSnackBar(
      SnackBar(content: Text(isSet ? _setMessage : _failedMessage)),
    );
  }

  Future<Uint8List?> _renderPoster(double pixelRatio) async {
    final boundary = _posterKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      return null;
    }
    try {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return bytes?.buffer.asUint8List();
    } catch (failure) {
      // A poster that cannot be captured is reported as a failed wallpaper.
      return null;
    }
  }
}

class _SetButton extends StatelessWidget {
  const _SetButton({
    required this.label,
    required this.target,
    required this.pending,
    required this.onPressed,
    this.style = PillStyle.filled,
  });

  static const double _spinner = 20;
  static const double _stroke = 2;

  final String label;
  final WallpaperTarget target;
  final WallpaperTarget? pending;
  final ValueChanged<WallpaperTarget> onPressed;
  final PillStyle style;

  @override
  Widget build(BuildContext context) {
    final button = PillButton(
      label: label,
      style: style,
      onPressed: pending == null ? () => onPressed(target) : null,
    );
    if (pending != target) {
      return button;
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        button,
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spaceLg),
          child: SizedBox.square(
            dimension: _spinner,
            child: CircularProgressIndicator(
              strokeWidth: _stroke,
              color: style == PillStyle.filled
                  ? AppTheme.onAccent
                  : AppTheme.chalk,
            ),
          ),
        ),
      ],
    );
  }
}
