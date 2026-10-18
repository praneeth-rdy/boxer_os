import 'package:boxer_os/models/reaction_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactionDirection.icon', () {
    test('maps each direction to its own arrow icon', () {
      expect(ReactionDirection.up.icon, Icons.arrow_upward_rounded);
      expect(ReactionDirection.down.icon, Icons.arrow_downward_rounded);
      expect(ReactionDirection.left.icon, Icons.arrow_back_rounded);
      expect(ReactionDirection.right.icon, Icons.arrow_forward_rounded);
    });

    test('every direction maps to a distinct icon', () {
      final icons = ReactionDirection.values.map((d) => d.icon).toSet();

      expect(icons.length, ReactionDirection.values.length);
    });
  });
}
