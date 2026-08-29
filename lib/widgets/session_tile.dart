import 'package:flutter/material.dart';

import '../models/session_record.dart';
import '../theme/app_theme.dart';

/// One stored session as a tappable row: name, shape and how it felt.
class SessionTile extends StatelessWidget {
  const SessionTile({required this.record, required this.onTap, super.key});

  static const double _minHeight = 72;

  final SessionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rating = record.rating;
    final summary =
        '${record.type.label} · ${record.roundsCompleted} rounds '
        '· ${record.workMinutes} min${record.completed ? '' : ' · ended early'}';

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
                      Text(record.workoutName, style: AppTheme.title),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(summary, style: AppTheme.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Text(
                  rating == null ? '--' : '$rating/5',
                  style: rating == null
                      ? AppTheme.displaySmall.copyWith(
                          color: AppTheme.chalkFaint,
                        )
                      : AppTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
