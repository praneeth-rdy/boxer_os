import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../utils/duration_format.dart';
import '../utils/session_launcher.dart';
import 'pill_button.dart';
import 'stepper_row.dart';

/// Round timer built from the boxer's own numbers, started in one tap.
class QuickTimerCard extends StatefulWidget {
  const QuickTimerCard({super.key});

  @override
  State<QuickTimerCard> createState() => _QuickTimerCardState();
}

class _QuickTimerCardState extends State<QuickTimerCard> {
  static const int _minRounds = 1;
  static const int _maxRounds = 30;
  static const int _secondsStep = 15;
  static const int _minWorkSeconds = 30;
  static const int _maxWorkSeconds = 600;
  static const int _minRestSeconds = 0;
  static const int _maxRestSeconds = 300;

  int rounds = 3;
  int workSeconds = 180;
  int restSeconds = 60;

  Workout get _workout => Workout.quick(
    rounds: rounds,
    workSeconds: workSeconds,
    restSeconds: restSeconds,
  );

  @override
  Widget build(BuildContext context) {
    final roundWord = rounds == 1 ? 'round' : 'rounds';
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROUND TIMER', style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceSm),
          const Text('Quick start', style: AppTheme.displayMedium),
          const SizedBox(height: AppTheme.spaceLg),
          StepperRow(
            label: 'Rounds',
            value: '$rounds',
            onDecrement: rounds > _minRounds
                ? () => setState(() => rounds--)
                : null,
            onIncrement: rounds < _maxRounds
                ? () => setState(() => rounds++)
                : null,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          StepperRow(
            label: 'Work',
            value: formatClock(workSeconds),
            onDecrement: workSeconds > _minWorkSeconds
                ? () => setState(() => workSeconds -= _secondsStep)
                : null,
            onIncrement: workSeconds < _maxWorkSeconds
                ? () => setState(() => workSeconds += _secondsStep)
                : null,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          StepperRow(
            label: 'Rest',
            value: formatClock(restSeconds),
            onDecrement: restSeconds > _minRestSeconds
                ? () => setState(() => restSeconds -= _secondsStep)
                : null,
            onIncrement: restSeconds < _maxRestSeconds
                ? () => setState(() => restSeconds += _secondsStep)
                : null,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            '$rounds $roundWord, about ${_workout.estimatedMinutes} min',
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          PillButton(
            label: 'Start',
            height: AppTheme.minTapTarget + AppTheme.spaceSm,
            onPressed: () => startSession(context, _workout),
          ),
        ],
      ),
    );
  }
}
