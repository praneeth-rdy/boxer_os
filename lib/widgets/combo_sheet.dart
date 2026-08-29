import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/combination.dart';
import '../providers/combos_provider.dart';
import '../theme/app_theme.dart';
import '../utils/practice_builder.dart';
import '../utils/session_launcher.dart';
import 'pill_button.dart';

const int _practiceRounds = 3;
const int _practiceRoundSeconds = 120;
const double _actionHeight = 56;

/// Opens the detail sheet for [combination] and starts its drill on request.
Future<void> showComboSheet(
  BuildContext context,
  Combination combination,
) async {
  final startPractice = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppTheme.surfaceRaised,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLg),
      ),
    ),
    builder: (_) => _ComboSheet(combination: combination),
  );
  if (startPractice != true || !context.mounted) {
    return;
  }
  await startSession(
    context,
    buildPracticeWorkout(
      combinations: [combination],
      rounds: _practiceRounds,
      roundSeconds: _practiceRoundSeconds,
      difficulty: combination.difficulty,
    ),
  );
}

class _ComboSheet extends StatelessWidget {
  const _ComboSheet({required this.combination});

  final Combination combination;

  @override
  Widget build(BuildContext context) {
    final isSaved = context.select<CombosProvider, bool>(
      (combos) => combos.isSaved(combination),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg,
          0,
          AppTheme.spaceLg,
          AppTheme.spaceLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                combination.notation,
                style: AppTheme.displayLarge,
                maxLines: 2,
              ),
            ),
            if (combination.name.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceSm),
              Text(combination.name, style: AppTheme.title),
            ],
            if (combination.description.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Text(combination.description, style: AppTheme.bodyMuted),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            const Text('SPOKEN', style: AppTheme.label),
            const SizedBox(height: AppTheme.spaceSm),
            Text(combination.spoken, style: AppTheme.body),
            if (combination.tags.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Wrap(
                spacing: AppTheme.spaceSm,
                children: [
                  for (final tag in combination.tags)
                    Chip(label: Text(tag.label)),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            PillButton(
              label: 'Practice this',
              onPressed: () => Navigator.of(context).pop(true),
              height: _actionHeight,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            PillButton(
              label: isSaved ? 'Saved' : 'Save',
              onPressed: () =>
                  context.read<CombosProvider>().toggleSaved(combination),
              style: PillStyle.outlined,
              height: _actionHeight,
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
