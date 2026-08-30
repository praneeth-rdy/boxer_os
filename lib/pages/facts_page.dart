import 'package:flutter/material.dart';

import '../data/boxing_facts.dart';
import '../theme/app_theme.dart';
import '../widgets/fact_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';

/// Every bundled fact, one card each.
class FactsPage extends StatelessWidget {
  const FactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        itemCount: boxingFacts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SettleIn(
              child: SectionHeader(
                title: 'Did you know',
                eyebrow: 'FROM THE RING',
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            child: FactCard(fact: boxingFacts[index - 1]),
          );
        },
      ),
    );
  }
}
