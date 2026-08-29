import 'package:flutter/material.dart';

import '../models/boxing_fact.dart';
import '../theme/app_theme.dart';

/// One piece of boxing history as a raised card under a "DID YOU KNOW" eyebrow.
class FactCard extends StatelessWidget {
  const FactCard({required this.fact, super.key});

  final BoxingFact fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DID YOU KNOW · ${fact.subject.toUpperCase()}',
            style: AppTheme.label,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(fact.text, style: AppTheme.body),
        ],
      ),
    );
  }
}
