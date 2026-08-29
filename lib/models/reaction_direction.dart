import 'package:flutter/material.dart';

/// The edge a direction-mode stimulus points to.
enum ReactionDirection {
  up,
  down,
  left,
  right;

  IconData get icon => switch (this) {
    ReactionDirection.up => Icons.arrow_upward_rounded,
    ReactionDirection.down => Icons.arrow_downward_rounded,
    ReactionDirection.left => Icons.arrow_back_rounded,
    ReactionDirection.right => Icons.arrow_forward_rounded,
  };
}
