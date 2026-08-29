import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_record.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_tile.dart';

const List<String> _monthNames = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// One stored session, read only, with the notes and a delete action.
class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        final record = history.findSession(id);
        return Scaffold(
          backgroundColor: AppTheme.ink,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              if (record != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppTheme.chalkMuted,
                  onPressed: () => _confirmDelete(context, history),
                ),
            ],
          ),
          body: record == null
              ? const Padding(
                  padding: EdgeInsets.all(AppTheme.spaceLg),
                  child: Text('Session not found', style: AppTheme.bodyMuted),
                )
              : _Detail(record: record),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HistoryProvider history,
  ) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceRaised,
        title: const Text('Delete this session?', style: AppTheme.titleLarge),
        content: const Text(
          'It leaves your history and your totals.',
          style: AppTheme.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    // Leave first: this page has nothing to show once the record is gone.
    navigator.pop();
    await history.deleteSession(id);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.record});

  final SessionRecord record;

  @override
  Widget build(BuildContext context) {
    final rating = record.rating;
    final whatWorked = record.whatWorked;
    final whatNeedsWork = record.whatNeedsWork;
    final opponent = record.opponent;
    final opponentStance = record.opponentStance;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        Text(
          '${record.type.label.toUpperCase()} · ${_moment(record.startedAt)}',
          style: AppTheme.label,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(record.workoutName, style: AppTheme.displayLarge),
        if (!record.completed) ...[
          const SizedBox(height: AppTheme.spaceXs),
          const Text('Ended early', style: AppTheme.caption),
        ],
        const SizedBox(height: AppTheme.spaceXl),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: record.roundsCompleted,
                suffix: '/${record.roundsPlanned}',
                label: 'ROUNDS',
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: StatTile(value: record.workMinutes, label: 'MINUTES'),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: rating == null
                  ? const StatTile.text('--', label: 'RATING')
                  : StatTile(value: rating, suffix: '/5', label: 'RATING'),
            ),
          ],
        ),
        if (whatWorked != null) _Note(label: 'WHAT WORKED', text: whatWorked),
        if (whatNeedsWork != null)
          _Note(label: 'WHAT NEEDS WORK', text: whatNeedsWork),
        if (opponent != null)
          _Note(
            label: opponentStance == null
                ? 'OPPONENT'
                : 'OPPONENT · ${opponentStance.label.toUpperCase()}',
            text: opponent,
          ),
      ],
    );
  }

  static String _moment(DateTime startedAt) {
    final minute = startedAt.minute.toString().padLeft(2, '0');
    return '${startedAt.day} ${_monthNames[startedAt.month - 1]} '
        '${startedAt.year} · ${startedAt.hour}:$minute';
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceSm),
          Text(text, style: AppTheme.body),
        ],
      ),
    );
  }
}
