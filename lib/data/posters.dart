import 'package:flutter/material.dart';

import '../models/legend.dart';
import '../models/poster.dart';
import 'legends.dart';
import 'quotes.dart';
import 'wall_photos.dart';

/// The lines each tagline poster paints, in poster order.
const List<List<String>> taglineLines = [
  ['TRAIN.', 'FIGHT.', 'IMPROVE.', 'REPEAT.'],
  ['TRAIN. FIGHT. IMPROVE. REPEAT.'],
  ['ROUND ONE', 'IS WAITING.'],
  ['PHONE DOWN.', 'GLOVES UP.'],
];

/// The tagline poster that paints the mark large over its single small line.
const int markPosterVariant = 1;

const List<String> _taglineTitles = [
  'Train. Fight. Improve. Repeat.',
  'The mark',
  'Round one is waiting.',
  'Phone down. Gloves up.',
];

/// Whose portrait is too small to fill a wallpaper.
const String _archivePosterLegend = 'pacquiao';

/// Every poster on the Gym Wall: the taglines, the legends, the archive
/// moments, the inspiration photos, then the quotes.
List<Poster> posters() => [
  for (var variant = 0; variant < taglineLines.length; variant++)
    Poster(
      id: 'tagline_$variant',
      kind: PosterKind.tagline,
      title: _taglineTitles[variant],
      variant: variant,
    ),
  for (final legend in legends)
    Poster(
      id: 'legend_${legend.id}',
      kind: PosterKind.legend,
      title: legend.name,
      legend: legend,
    ),
  for (final legend in legends)
    for (var index = 0; index < legend.gallery.length; index++)
      Poster(
        id: 'moment_${legend.id}_${index + 1}',
        kind: PosterKind.moment,
        title: legend.name,
        legend: legend,
        gallery: legend.gallery[index],
      ),
  for (final photo in wallPhotos)
    Poster(
      id: 'wall_${photo.id}',
      kind: PosterKind.inspiration,
      title: photo.line,
      photo: photo,
    ),
  for (var index = 0; index < quotes.length; index++)
    Poster(
      id: 'quote_$index',
      kind: PosterKind.quote,
      title: quotes[index].author,
      quote: quotes[index],
    ),
];

/// The photo a legend poster fills its frame with.
String posterPhotoAsset(Legend legend) =>
    _archivePhoto(legend)?.asset ?? legend.imageAsset;

/// Where that photo is held while it is cropped to the poster.
Alignment posterPhotoFocus(Legend legend) =>
    _archivePhoto(legend) == null ? legend.photoFocus : Alignment.center;

/// The credit baked into the bottom of a legend poster.
String posterCredit(Legend legend) {
  final credit = _archivePhoto(legend)?.credit ?? legend.credit;
  return 'Photo: ${credit.author} · ${credit.license}';
}

GalleryPhoto? _archivePhoto(Legend legend) =>
    legend.id == _archivePosterLegend ? legend.gallery.first : null;
