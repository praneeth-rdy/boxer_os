import 'package:flutter/material.dart';

import '../data/footwork_drills.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/workout_tile.dart';
import 'workout_detail_page.dart';

/// The footwork catalogue: every movement drill, opened as a normal workout.
class FootworkPage extends StatelessWidget {
  const FootworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          const SectionHeader(title: 'Footwork', eyebrow: 'MOVEMENT DRILLS'),
          for (var index = 0; index < footworkDrills.length; index++) ...[
            if (index > 0) const SizedBox(height: AppTheme.spaceSm),
            WorkoutTile(
              workout: footworkDrills[index],
              onTap: () => _openDrill(context, footworkDrills[index]),
            ),
          ],
        ],
      ),
    );
  }

  void _openDrill(BuildContext context, Workout drill) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailPage(workout: drill),
      ),
    );
  }
}
