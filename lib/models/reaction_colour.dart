import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One of the four colours a colour-call trial prints and names.
enum ReactionColour {
  red,
  mint,
  amber,
  chalk;

  String get label => switch (this) {
    ReactionColour.red => 'RED',
    ReactionColour.mint => 'MINT',
    ReactionColour.amber => 'AMBER',
    ReactionColour.chalk => 'CHALK',
  };

  /// The colour itself, as it fills a zone or paints the word.
  Color get swatch => switch (this) {
    ReactionColour.red => AppTheme.accent,
    ReactionColour.mint => AppTheme.rest,
    ReactionColour.amber => AppTheme.warning,
    ReactionColour.chalk => AppTheme.chalk,
  };

  /// The colour a label stays readable in on top of [swatch].
  Color get onSwatch => switch (this) {
    ReactionColour.red || ReactionColour.mint => AppTheme.chalk,
    ReactionColour.amber || ReactionColour.chalk => AppTheme.ink,
  };
}
