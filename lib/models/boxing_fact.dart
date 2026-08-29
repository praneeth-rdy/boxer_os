/// One piece of boxing history, with the boxer or event it is about.
class BoxingFact {
  const BoxingFact({required this.text, required this.subject});

  final String text;

  /// The boxer or event named, shown as the card's eyebrow.
  final String subject;
}
