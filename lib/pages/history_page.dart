import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_record.dart';
import '../providers/history_provider.dart';
import '../providers/shell_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/session_tile.dart';
import 'session_detail_page.dart';

const List<String> _weekdayNames = [
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];
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
const int _trainTab = 1;

/// Every stored session, newest first, grouped under its day.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {
          final sessions = history.sessions;
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            children: [
              const SectionHeader(
                title: 'History',
                eyebrow: 'EVERY ROUND YOU LOGGED',
              ),
              if (sessions.isEmpty)
                const _EmptyHistory()
              else
                ..._daySections(context, sessions),
            ],
          );
        },
      ),
    );
  }

  static List<Widget> _daySections(
    BuildContext context,
    List<SessionRecord> sessions,
  ) {
    final now = DateTime.now();
    final sections = <Widget>[];
    DateTime? day;
    for (final record in sessions) {
      if (day == null || !isSameDay(record.startedAt, day)) {
        day = startOfDay(record.startedAt);
        if (sections.isNotEmpty) {
          sections.add(const SizedBox(height: AppTheme.spaceLg));
        }
        sections.add(Text(_dayHeader(day, now), style: AppTheme.label));
      }
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: AppTheme.spaceSm),
          child: SessionTile(
            record: record,
            onTap: () => _openDetail(context, record.id),
          ),
        ),
      );
    }
    return sections;
  }

  static String _dayHeader(DateTime day, DateTime now) {
    if (isSameDay(day, now)) {
      return 'TODAY';
    }
    if (isSameDay(day, DateTime(now.year, now.month, now.day - 1))) {
      return 'YESTERDAY';
    }
    return '${_weekdayNames[day.weekday - 1]} ${day.day} '
        '${_monthNames[day.month - 1]}';
  }

  static void _openDetail(BuildContext context, String id) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => SessionDetailPage(id: id)));
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      eyebrow: 'NOTHING LOGGED YET',
      title: 'Your first session lands here.',
      body:
          'Every finished session is saved with your rating and notes. '
          'Sparring days get opponent notes too.',
      actionLabel: 'Go to Train',
      onAction: () => _goToTrain(context),
    );
  }

  void _goToTrain(BuildContext context) {
    final shell = context.read<ShellProvider>();
    Navigator.of(context).pop();
    shell.showTab(_trainTab);
  }
}
