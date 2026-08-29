import 'package:flutter/material.dart';

import '../models/round_spec.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';
import '../utils/session_launcher.dart';
import '../widgets/pill_button.dart';

/// One library workout in full: its shape, its rounds and the start button.
class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({required this.workout, super.key});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final workSeconds = workout.rounds.isEmpty
        ? 0
        : workout.rounds.first.workSeconds;

    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
        children: [
          Text(
            '${workout.type.label} · ${workout.difficulty.label}'.toUpperCase(),
            style: AppTheme.label,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(workout.name, style: AppTheme.displayLarge),
          if (workout.description.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Text(workout.description, style: AppTheme.bodyMuted),
          ],
          const SizedBox(height: AppTheme.spaceXl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatCell(value: '${workout.roundCount}', label: 'Rounds'),
              _StatCell(value: formatClock(workSeconds), label: 'Work'),
              _StatCell(value: '${workout.estimatedMinutes}', label: 'Minutes'),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXl),
          const Text('ROUNDS', style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceMd),
          for (var index = 0; index < workout.rounds.length; index++) ...[
            if (index > 0) const SizedBox(height: AppTheme.spaceMd),
            _RoundRow(number: index + 1, round: workout.rounds[index]),
          ],
          const SizedBox(height: AppTheme.spaceLg),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: PillButton(
            label: 'Start workout',
            height: AppTheme.minTapTarget + AppTheme.spaceSm,
            onPressed: () => startSession(context, workout),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.displayMedium, maxLines: 1),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(label.toUpperCase(), style: AppTheme.label),
        ],
      ),
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({required this.number, required this.round});

  final int number;
  final RoundSpec round;

  static const double _numberWidth = 44;

  @override
  Widget build(BuildContext context) {
    final cueCount = round.cues.length;
    final detail = StringBuffer(
      '${formatClock(round.workSeconds)} work · '
      '${formatClock(round.restSeconds)} rest',
    );
    if (cueCount > 0) {
      detail.write(' · $cueCount ${cueCount == 1 ? 'cue' : 'cues'}');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _numberWidth,
          child: Text('R$number', style: AppTheme.bodyStrong),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                round.focus.isEmpty ? 'Free round' : round.focus,
                style: AppTheme.body,
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(detail.toString(), style: AppTheme.caption),
            ],
          ),
        ),
      ],
    );
  }
}
