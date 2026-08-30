/// Who took the photograph of a legend and under what licence it is used.
class PhotoCredit {
  const PhotoCredit({
    required this.author,
    required this.license,
    required this.source,
  });

  final String author;
  final String license;

  /// The file page the photo came from.
  final String source;
}

/// One chapter of a legend's story, headed by its own title.
class StorySection {
  const StorySection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// One boxer's story: who they were, what broke them and what to take from it.
class Legend {
  const Legend({
    required this.id,
    required this.name,
    required this.nickname,
    required this.years,
    required this.country,
    required this.division,
    required this.record,
    required this.hook,
    required this.sections,
    required this.quoteIndexes,
    required this.takeaways,
    required this.imageAsset,
    required this.credit,
  });

  final String id;
  final String name;
  final String nickname;

  /// Life span, or the birth year for a living boxer.
  final String years;
  final String country;
  final String division;
  final String record;

  /// One line that says why this boxer is worth reading about.
  final String hook;
  final List<StorySection> sections;

  /// Positions in `quotes`, the pull quotes shown with the story.
  final List<int> quoteIndexes;
  final List<String> takeaways;
  final String imageAsset;
  final PhotoCredit credit;
}
