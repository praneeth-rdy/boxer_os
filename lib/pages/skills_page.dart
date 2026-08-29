import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import '../widgets/skill_card.dart';
import 'combos_page.dart';
import 'footwork_page.dart';
import 'reaction_page.dart';

/// The Skills hub: combinations, reaction work and footwork.
class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            const SettleIn(
              child: SectionHeader(
                title: 'Skills',
                eyebrow: 'COMBOS, REACTION, FOOTWORK',
              ),
            ),
            SettleIn(
              index: 1,
              child: SkillCard(
                title: 'Combos',
                description:
                    'Generate combinations and drill them with spoken cues.',
                icon: Icons.sports_mma_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CombosPage()),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 2,
              child: SkillCard(
                title: 'Reaction',
                description: 'Test and train your reaction time.',
                icon: Icons.flash_on_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ReactionPage()),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            SettleIn(
              index: 3,
              child: SkillCard(
                title: 'Footwork',
                description: 'Movement drills on the round timer.',
                icon: Icons.directions_run_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const FootworkPage()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
