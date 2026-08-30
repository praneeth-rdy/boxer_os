import 'package:flutter/material.dart';

import '../data/boxing_calendar.dart';
import '../data/legends.dart';
import '../models/boxing_event.dart';
import '../models/legend.dart';
import '../pages/legend_story_page.dart';
import '../theme/app_theme.dart';
import 'pill_button.dart';

const double _actionHeight = 56;
const double _readingHeight = 1.5;

/// Opens the detail sheet for [event] and its legend's story on request.
Future<void> showEventSheet(BuildContext context, BoxingEvent event) async {
  final legend = await showModalBottomSheet<Legend>(
    context: context,
    backgroundColor: AppTheme.surfaceRaised,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLg),
      ),
    ),
    builder: (_) => _EventSheet(event: event),
  );
  if (legend == null || !context.mounted) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => LegendStoryPage(legend: legend)),
  );
}

/// The day line: "30 OCTOBER 1974", or "6 APRIL, EVERY YEAR" without a year.
String eventDateLine(BoxingEvent event) {
  final day = '${event.day} ${monthName(event.month).toUpperCase()}';
  return event.year == null ? '$day, EVERY YEAR' : '$day ${event.year}';
}

class _EventSheet extends StatelessWidget {
  const _EventSheet({required this.event});

  final BoxingEvent event;

  @override
  Widget build(BuildContext context) {
    final legendId = event.legendId;
    final legend = legendId == null ? null : findLegend(legendId);
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
            Text(eventDateLine(event), style: AppTheme.label),
            const SizedBox(height: AppTheme.spaceSm),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(label: Text(event.kind.label)),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            // The longest titles run to fifty characters, so the display face
            // wraps rather than scaling itself down to a caption.
            Text(event.title, style: AppTheme.displayLarge),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              event.blurb,
              style: AppTheme.body.copyWith(height: _readingHeight),
            ),
            if (legend != null) ...[
              const SizedBox(height: AppTheme.spaceLg),
              PillButton(
                label: 'Read the legend',
                height: _actionHeight,
                onPressed: () => Navigator.of(context).pop(legend),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
