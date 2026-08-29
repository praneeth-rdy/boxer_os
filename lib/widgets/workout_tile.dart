import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';

/// One library workout as a tappable row: name, shape and total minutes.
class WorkoutTile extends StatelessWidget {
  const WorkoutTile({required this.workout, required this.onTap, super.key});

  final Workout workout;
  final VoidCallback onTap;

  static const double _minHeight = 72;

  @override
  Widget build(BuildContext context) {
    final workSeconds = workout.rounds.isEmpty
        ? 0
        : workout.rounds.first.workSeconds;
    final shape =
        '${workout.roundCount} x ${formatClock(workSeconds)} '
        '· ${workout.difficulty.label}';

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(workout.name, style: AppTheme.title),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(shape, style: AppTheme.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${workout.estimatedMinutes}',
                      style: AppTheme.displaySmall,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    const Text('MIN', style: AppTheme.label),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
