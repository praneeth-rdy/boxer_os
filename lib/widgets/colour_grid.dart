import 'package:flutter/material.dart';

import '../models/reaction_colour.dart';
import '../theme/app_theme.dart';

/// The four colour answers as a 2 x 2 hit grid, with [centre] stacked over it.
class ColourGrid extends StatelessWidget {
  const ColourGrid({required this.onColour, this.centre, super.key});

  final void Function(ReactionColour) onColour;

  final Widget? centre;

  @override
  Widget build(BuildContext context) {
    final overlay = centre;
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _zone(ReactionColour.red, Alignment.topLeft),
                  _zone(ReactionColour.mint, Alignment.topRight),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _zone(ReactionColour.amber, Alignment.bottomLeft),
                  _zone(ReactionColour.chalk, Alignment.bottomRight),
                ],
              ),
            ),
          ],
        ),
        if (overlay != null) IgnorePointer(child: Center(child: overlay)),
      ],
    );
  }

  Widget _zone(ReactionColour colour, Alignment corner) => Expanded(
    child: _ColourZoneTile(colour: colour, corner: corner, onTap: onColour),
  );
}

/// One quarter of the grid; taps register on press, not on release.
class _ColourZoneTile extends StatelessWidget {
  const _ColourZoneTile({
    required this.colour,
    required this.corner,
    required this.onTap,
  });

  final ReactionColour colour;
  final Alignment corner;
  final void Function(ReactionColour) onTap;

  static const double _fillAlpha = 0.85;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTap(colour),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colour.swatch.withValues(alpha: _fillAlpha),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Align(
            alignment: corner,
            child: Text(
              colour.label,
              style: AppTheme.label.copyWith(color: colour.onSwatch),
            ),
          ),
        ),
      ),
    );
  }
}
