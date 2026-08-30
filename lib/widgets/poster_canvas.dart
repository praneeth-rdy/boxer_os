import 'package:flutter/material.dart';

import '../data/posters.dart';
import '../models/legend.dart';
import '../models/poster.dart';
import '../models/quote.dart';
import '../models/wall_photo.dart';
import '../theme/app_theme.dart';

/// Every measurement on a poster is a fraction of its width, so the same
/// canvas reads the same in a thumbnail and at the phone's full resolution.
const double _marginFraction = 0.089;
const double _gapFraction = 0.025;
const double _markFraction = 0.15;
const double _bigMarkFraction = 0.42;
const double _lineFraction = 0.155;
const double _quoteFraction = 0.13;
const double _nameFraction = 0.34;
const double _authorFraction = 0.05;
const double _labelFraction = 0.036;
const double _bodyFraction = 0.042;
const double _captionFraction = 0.03;
const double _momentCaptionFraction = 0.11;
const double _inspirationLineFraction = 0.16;

/// One poster painted at [size] logical pixels, ready to be captured as a wallpaper.
class PosterCanvas extends StatelessWidget {
  const PosterCanvas({required this.poster, required this.size, super.key});

  final Poster poster;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final legend = poster.legend;
    final quote = poster.quote;
    final gallery = poster.gallery;
    final photo = poster.photo;
    return MediaQuery.withNoTextScaling(
      child: SizedBox.fromSize(
        size: size,
        child: ColoredBox(
          color: AppTheme.ink,
          child: switch (poster.kind) {
            PosterKind.tagline => _TaglinePoster(
              variant: poster.variant ?? 0,
              width: size.width,
            ),
            PosterKind.legend when legend != null => _LegendPoster(
              legend: legend,
              width: size.width,
            ),
            PosterKind.moment when legend != null && gallery != null =>
              _MomentPoster(legend: legend, photo: gallery, width: size.width),
            PosterKind.inspiration when photo != null => _InspirationPoster(
              photo: photo,
              width: size.width,
            ),
            PosterKind.quote when quote != null => _QuotePoster(
              quote: quote,
              width: size.width,
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _TaglinePoster extends StatelessWidget {
  const _TaglinePoster({required this.variant, required this.width});

  final int variant;
  final double width;

  @override
  Widget build(BuildContext context) {
    final lines = taglineLines[variant];
    if (variant == markPosterVariant) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CornerMark(size: width * _bigMarkFraction),
            SizedBox(height: width * _marginFraction),
            Text(
              lines.first,
              style: AppTheme.label.copyWith(fontSize: width * _labelFraction),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(width * _marginFraction),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CornerMark(size: width * _markFraction),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final line in lines)
                      Text(
                        line,
                        style: AppTheme.displayLarge.copyWith(
                          fontSize: width * _lineFraction,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotePoster extends StatelessWidget {
  const _QuotePoster({required this.quote, required this.width});

  final Quote quote;
  final double width;

  @override
  Widget build(BuildContext context) {
    final margin = width * _marginFraction;
    return Padding(
      padding: EdgeInsets.all(margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CornerMark(size: width * _markFraction),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: width - margin * 2,
                  child: Text(
                    '"${quote.text}"',
                    style: AppTheme.displayLarge.copyWith(
                      fontSize: width * _quoteFraction,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            quote.author.toUpperCase(),
            style: AppTheme.displaySmall.copyWith(
              fontSize: width * _authorFraction,
              color: AppTheme.accent,
            ),
          ),
          SizedBox(height: width * _gapFraction),
          Text(
            quote.sport.toUpperCase(),
            style: AppTheme.label.copyWith(fontSize: width * _labelFraction),
          ),
        ],
      ),
    );
  }
}

class _LegendPoster extends StatelessWidget {
  const _LegendPoster({required this.legend, required this.width});

  static const List<double> _scrimStops = [0.3, 0.66, 1];
  static const double _scrimMidAlpha = 0.65;

  final Legend legend;
  final double width;

  @override
  Widget build(BuildContext context) {
    final gap = width * _gapFraction;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          posterPhotoAsset(legend),
          fit: BoxFit.cover,
          alignment: posterPhotoFocus(legend),
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stack) =>
              const ColoredBox(color: AppTheme.surfaceRaised),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: _scrimStops,
              colors: [
                AppTheme.ink.withValues(alpha: 0),
                AppTheme.ink.withValues(alpha: _scrimMidAlpha),
                AppTheme.ink,
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(width * _marginFraction),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CornerMark(size: width * _markFraction),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  legend.name.toUpperCase().split(' ').join('\n'),
                  style: AppTheme.displayHero.copyWith(
                    fontSize: width * _nameFraction,
                  ),
                ),
              ),
              SizedBox(height: gap),
              Text(
                '${legend.nickname} · ${legend.years}'.toUpperCase(),
                style: AppTheme.label.copyWith(
                  fontSize: width * _labelFraction,
                  color: AppTheme.accent,
                ),
              ),
              SizedBox(height: gap),
              Text(
                posterCredit(legend),
                style: AppTheme.caption.copyWith(
                  fontSize: width * _captionFraction,
                  color: AppTheme.chalkFaint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MomentPoster extends StatelessWidget {
  const _MomentPoster({
    required this.legend,
    required this.photo,
    required this.width,
  });

  final Legend legend;
  final GalleryPhoto photo;
  final double width;

  @override
  Widget build(BuildContext context) {
    final gap = width * _gapFraction;
    return _PhotoGround(
      asset: photo.asset,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            legend.name.toUpperCase(),
            style: AppTheme.label.copyWith(
              fontSize: width * _labelFraction,
              color: AppTheme.accent,
            ),
          ),
          SizedBox(height: gap),
          Flexible(
            child: _ScaledBlock(
              width: width,
              child: Text(
                photo.caption,
                style: AppTheme.displayMedium.copyWith(
                  fontSize: width * _momentCaptionFraction,
                ),
              ),
            ),
          ),
          SizedBox(height: gap),
          _CreditLine(credit: photo.credit, width: width),
        ],
      ),
    );
  }
}

class _InspirationPoster extends StatelessWidget {
  const _InspirationPoster({required this.photo, required this.width});

  static const int _lineMaxLines = 3;

  final WallPhoto photo;
  final double width;

  @override
  Widget build(BuildContext context) {
    final gap = width * _gapFraction;
    return _PhotoGround(
      asset: photo.asset,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _ScaledBlock(
              width: width,
              child: Text(
                photo.line,
                maxLines: _lineMaxLines,
                style: AppTheme.displayLarge.copyWith(
                  fontSize: width * _inspirationLineFraction,
                ),
              ),
            ),
          ),
          SizedBox(height: gap),
          Text(
            photo.caption,
            style: AppTheme.bodyMuted.copyWith(fontSize: width * _bodyFraction),
          ),
          SizedBox(height: gap),
          _CreditLine(credit: photo.credit, width: width),
        ],
      ),
    );
  }
}

/// A photograph filling the poster under a scrim, with the mark over it and
/// [child] laid out in the margins.
class _PhotoGround extends StatelessWidget {
  const _PhotoGround({
    required this.asset,
    required this.width,
    required this.child,
  });

  static const List<double> _scrimStops = [0.45, 1];
  static const double _scrimBottomAlpha = 0.92;

  final String asset;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stack) =>
              const ColoredBox(color: AppTheme.surfaceRaised),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: _scrimStops,
              colors: [
                AppTheme.ink.withValues(alpha: 0),
                AppTheme.ink.withValues(alpha: _scrimBottomAlpha),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(width * _marginFraction),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CornerMark(size: width * _markFraction),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

/// Text held to the poster's column width and shrunk to whatever room is left.
class _ScaledBlock extends StatelessWidget {
  const _ScaledBlock({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomLeft,
      child: SizedBox(width: width - width * _marginFraction * 2, child: child),
    );
  }
}

/// Who took a photograph and under what licence, baked into the poster.
class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.credit, required this.width});

  final PhotoCredit credit;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${credit.author}, ${credit.license}',
      style: AppTheme.caption.copyWith(
        fontSize: width * _captionFraction,
        color: AppTheme.chalkFaint,
      ),
    );
  }
}

/// The Boxer OS mark: a red corner post with three ropes running off it.
class _CornerMark extends StatelessWidget {
  const _CornerMark({required this.size});

  static const double _postFraction = 0.19;
  static const double _ropeFraction = 0.085;
  static const List<double> _ropeStops = [0.2, 0.45, 0.7];

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          for (final stop in _ropeStops)
            Positioned(
              left: 0,
              right: 0,
              top: size * stop,
              height: size * _ropeFraction,
              child: const ColoredBox(color: AppTheme.chalk),
            ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: size * _postFraction,
            child: const ColoredBox(color: AppTheme.accent),
          ),
        ],
      ),
    );
  }
}
