import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Page or section heading with an optional uppercase eyebrow and trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.eyebrow,
    this.trailing,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final eyebrowText = eyebrow;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrowText != null) ...[
            Text(eyebrowText.toUpperCase(), style: AppTheme.label),
            const SizedBox(height: AppTheme.spaceSm),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(title, style: AppTheme.displayLarge)),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}
