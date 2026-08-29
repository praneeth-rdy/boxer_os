import 'package:flutter/material.dart';

import '../data/workout_library.dart';
import '../models/training_type.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_timer_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import '../widgets/workout_tile.dart';
import 'workout_detail_page.dart';

/// The round timer and the bundled workout library, grouped by training type.
class TrainPage extends StatelessWidget {
  const TrainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            const SettleIn(
              child: SectionHeader(
                title: 'Train',
                eyebrow: 'WORKOUTS AND TIMER',
              ),
            ),
            const SettleIn(index: 1, child: QuickTimerCard()),
            const SizedBox(height: AppTheme.spaceXl),
            for (final type in TrainingType.values)
              if (type != TrainingType.custom)
                SettleIn(
                  index: type.index + 2,
                  child: _WorkoutGroup(type: type),
                ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutGroup extends StatelessWidget {
  const _WorkoutGroup({required this.type});

  final TrainingType type;

  @override
  Widget build(BuildContext context) {
    final workouts = workoutsOfType(type);
    if (workouts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.label.toUpperCase(), style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceMd),
          for (var index = 0; index < workouts.length; index++) ...[
            if (index > 0) const SizedBox(height: AppTheme.spaceSm),
            WorkoutTile(
              workout: workouts[index],
              onTap: () => _openDetail(context, workouts[index]),
            ),
          ],
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailPage(workout: workout),
      ),
    );
  }
}
