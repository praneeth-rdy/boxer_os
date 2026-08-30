import 'package:flutter/material.dart';

import '../data/boxing_calendar.dart';
import '../models/boxing_event.dart';
import '../theme/app_theme.dart';

/// One calendar entry as a dated row, coloured when it is today or next up.
class EventTile extends StatelessWidget {
  const EventTile({
    required this.event,
    this.onTap,
    this.isToday = false,
    this.isNext = false,
    super.key,
  });

  static const double _dateWidth = 56;
  static const int _blurbLines = 3;

  final BoxingEvent event;
  final VoidCallback? onTap;
  final bool isToday;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final mark = isToday
        ? AppTheme.accent
        : isNext
        ? AppTheme.rest
        : null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _dateWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.day}',
                      style: mark == null
                          ? AppTheme.displayMedium
                          : AppTheme.displayMedium.copyWith(color: mark),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      monthAbbreviation(event.month).toUpperCase(),
                      style: mark == null
                          ? AppTheme.label
                          : AppTheme.label.copyWith(color: mark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: AppTheme.title),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      event.blurb,
                      style: AppTheme.bodyMuted,
                      maxLines: _blurbLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(event.subtitle, style: AppTheme.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
