import 'legend.dart';

/// One atmosphere photograph on the Gym Wall, with the line it carries.
class WallPhoto {
  const WallPhoto({
    required this.id,
    required this.asset,
    required this.line,
    required this.caption,
    required this.credit,
  });

  final String id;
  final String asset;

  /// The short line the poster paints over the photo.
  final String line;

  /// What the photograph shows.
  final String caption;
  final PhotoCredit credit;
}
