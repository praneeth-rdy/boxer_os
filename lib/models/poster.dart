import 'legend.dart';
import 'quote.dart';
import 'wall_photo.dart';

/// What a Gym Wall poster is made of.
enum PosterKind {
  tagline('Taglines'),
  legend('Legends'),
  moment('Moments'),
  inspiration('Inspiration'),
  quote('Quotes');

  const PosterKind(this.label);

  final String label;
}

/// One wallpaper poster: a tagline, a legend, an archive moment, an
/// inspiration photo or a quote, painted by the app.
class Poster {
  const Poster({
    required this.id,
    required this.kind,
    required this.title,
    this.quote,
    this.legend,
    this.gallery,
    this.photo,
    this.variant,
  });

  final String id;
  final PosterKind kind;

  /// How the poster is named in the gallery.
  final String title;
  final Quote? quote;

  /// The legend a legend or moment poster belongs to.
  final Legend? legend;

  /// The archive photograph a moment poster paints.
  final GalleryPhoto? gallery;

  /// The atmosphere photograph an inspiration poster paints.
  final WallPhoto? photo;

  /// Which of the tagline layouts to paint.
  final int? variant;
}
