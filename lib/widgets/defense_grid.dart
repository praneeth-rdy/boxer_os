import 'package:flutter/material.dart';

import '../models/defense_zone.dart';
import '../theme/app_theme.dart';

/// The four defense answers as a 2 x 2 hit grid, with [centre] stacked over it.
class DefenseGrid extends StatelessWidget {
  const DefenseGrid({
    required this.onZone,
    required this.isArmed,
    this.centre,
    super.key,
  });

  final void Function(DefenseZone) onZone;

  /// Whether a punch is live: armed labels are brighter than resting ones.
  final bool isArmed;

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
                  _zone(DefenseZone.slipLeft, Alignment.topLeft),
                  _zone(DefenseZone.slipRight, Alignment.topRight),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _zone(DefenseZone.roll, Alignment.bottomLeft),
                  _zone(DefenseZone.block, Alignment.bottomRight),
                ],
              ),
            ),
          ],
        ),
        if (overlay != null) IgnorePointer(child: Center(child: overlay)),
      ],
    );
  }

  Widget _zone(DefenseZone zone, Alignment corner) => Expanded(
    child: _DefenseZoneTile(
      zone: zone,
      corner: corner,
      isArmed: isArmed,
      onTap: onZone,
    ),
  );
}

/// One quarter of the grid; taps register on press, not on release.
class _DefenseZoneTile extends StatelessWidget {
  const _DefenseZoneTile({
    required this.zone,
    required this.corner,
    required this.isArmed,
    required this.onTap,
  });

  final DefenseZone zone;
  final Alignment corner;
  final bool isArmed;
  final void Function(DefenseZone) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTap(zone),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: AppTheme.line, width: AppTheme.hairline),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Align(
            alignment: corner,
            child: Text(
              zone.label,
              style: AppTheme.label.copyWith(
                color: isArmed ? AppTheme.chalkMuted : AppTheme.chalkFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
