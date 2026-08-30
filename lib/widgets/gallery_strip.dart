import 'package:flutter/material.dart';

import '../models/legend.dart';
import '../theme/app_theme.dart';
import '../utils/external_links.dart';

/// A legend's archive photos as a horizontal strip, each opening full screen.
class GalleryStrip extends StatelessWidget {
  const GalleryStrip({
    required this.photos,
    this.horizontalPadding = AppTheme.spaceLg,
    super.key,
  });

  final List<GalleryPhoto> photos;

  /// Inset of the first and last photo, so the strip itself can run edge to edge.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _GalleryItem.itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: photos.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppTheme.spaceMd),
        itemBuilder: (_, index) => _GalleryItem(photo: photos[index]),
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  const _GalleryItem({required this.photo});

  static const double _width = 280;
  static const double _ratio = 4 / 3;
  static const int _captionLines = 2;

  /// Line box of a 12 sp caption, rounded up so the fixed height never clips it.
  static const double _captionLine = 18;

  /// Photo, caption and credit, so the strip can be sized without measuring.
  static const double itemHeight =
      _width / _ratio +
      AppTheme.spaceSm +
      _captionLines * _captionLine +
      AppTheme.spaceXs +
      _captionLine;

  final GalleryPhoto photo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openViewer(context, photo),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: AspectRatio(
                aspectRatio: _ratio,
                child: Image.asset(
                  photo.asset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stack) =>
                      const ColoredBox(color: AppTheme.surfaceRaised),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            photo.caption,
            maxLines: _captionLines,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.caption,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          GestureDetector(
            onTap: () {
              openExternal(photo.credit.source);
            },
            child: Text(
              '${photo.credit.author}, ${photo.credit.license}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.caption.copyWith(color: AppTheme.chalkFaint),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openViewer(BuildContext context, GalleryPhoto photo) {
  return showDialog<void>(
    context: context,
    barrierColor: AppTheme.ink,
    builder: (_) => _PhotoViewer(photo: photo),
  );
}

/// One archive photo full screen, zoomable, closed by a tap outside it.
class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.photo});

  static const double _maxScale = 4;

  final GalleryPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: InteractiveViewer(
              maxScale: _maxScale,
              child: Image.asset(
                photo.asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const ColoredBox(color: AppTheme.surfaceRaised),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            photo.caption,
            textAlign: TextAlign.center,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}
