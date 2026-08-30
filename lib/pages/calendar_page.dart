import 'package:flutter/material.dart';

import '../data/boxing_calendar.dart';
import '../models/boxing_event.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/event_sheet.dart';
import '../widgets/event_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';

const int _monthsInYear = 12;

/// The boxing year month by month, opened on the month it is now.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime _now = DateTime.now();
  final Map<int, GlobalKey> _monthAnchors = {
    for (var month = 1; month <= _monthsInYear; month++) month: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showThisMonth());
  }

  void _showThisMonth() {
    if (!mounted) {
      return;
    }
    final anchor = _monthAnchors[_now.month]?.currentContext;
    if (anchor == null) {
      return;
    }
    Scrollable.ensureVisible(
      anchor,
      duration: AppMotion.of(context, AppMotion.base),
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = eventsOn(_now);
    final next = nextEvents(_now, count: 1);
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettleIn(
              child: SectionHeader(
                title: 'Calendar',
                eyebrow: 'DAYS THAT MATTER',
              ),
            ),
            const SettleIn(
              child: Text(
                "Anniversaries, birthdays and the sport's international days.",
                style: AppTheme.bodyMuted,
              ),
            ),
            for (var month = 1; month <= _monthsInYear; month++)
              SettleIn(
                index: month,
                child: _MonthGroup(
                  key: _monthAnchors[month],
                  month: month,
                  today: today,
                  next: next.isEmpty ? null : next.first,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthGroup extends StatelessWidget {
  const _MonthGroup({
    required this.month,
    required this.today,
    required this.next,
    super.key,
  });

  final int month;
  final List<BoxingEvent> today;
  final BoxingEvent? next;

  @override
  Widget build(BuildContext context) {
    final events = boxingCalendar.where((event) => event.month == month);
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthName(month).toUpperCase(), style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceSm),
          for (final event in events)
            EventTile(
              event: event,
              onTap: () => showEventSheet(context, event),
              isToday: today.contains(event),
              isNext: event == next,
            ),
        ],
      ),
    );
  }
}
