import 'package:flutter/material.dart';

import '../models/boxing_event.dart';
import '../theme/app_theme.dart';
import 'event_sheet.dart';

/// One calendar entry as a raised card, opening its detail sheet.
class EventCard extends StatelessWidget {
  const EventCard({required this.event, super.key});

  final BoxingEvent event;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showEventSheet(context, event),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: AppTheme.displayMedium),
              const SizedBox(height: AppTheme.spaceSm),
              Text(event.blurb, style: AppTheme.body),
              const SizedBox(height: AppTheme.spaceSm),
              Text(event.subtitle, style: AppTheme.caption),
            ],
          ),
        ),
      ),
    );
  }
}
