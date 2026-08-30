import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/quotes.dart';
import '../models/difficulty.dart';
import '../models/stance.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/journal_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/quote_card.dart';
import '../widgets/settle_in.dart';
import 'app_shell.dart';

const int _stepCount = 3;
const double _actionHeight = 56;
const Duration _pageTurn = Duration(milliseconds: 240);

/// First launch: the name, the stance and the level, in three steps.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pages = PageController();
  final TextEditingController _name = TextEditingController();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _name.text = context.read<SettingsProvider>().fighterName;
  }

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _step == _stepCount - 1;
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: AppTheme.minTapTarget,
              child: Align(
                alignment: Alignment.centerRight,
                child: _step == 0 ? _SkipButton(onSkip: _finish) : null,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (index) => setState(() => _step = index),
                children: [
                  _NameStep(controller: _name),
                  const _StanceStep(),
                  const _LevelStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: PillButton(
                        label: 'Back',
                        style: PillStyle.ghost,
                        height: _actionHeight,
                        onPressed: _back,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                  ],
                  Expanded(
                    child: PillButton(
                      label: isLastStep ? 'Start training' : 'Next',
                      height: _actionHeight,
                      onPressed: isLastStep ? _finish : _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _pages.animateToPage(_step + 1, duration: _pageTurn, curve: Curves.easeOut);
  }

  void _back() {
    _pages.animateToPage(_step - 1, duration: _pageTurn, curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    final settings = context.read<SettingsProvider>();
    await settings.setFighterName(_name.text);
    await settings.setOnboardingDone(true);
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onSkip,
      child: Text(
        'Skip',
        style: AppTheme.bodyStrong.copyWith(color: AppTheme.chalkMuted),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      children: [
        const SettleIn(
          child: Text('TRAIN. FIGHT. IMPROVE. REPEAT.', style: AppTheme.label),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        const SettleIn(child: Text('BOXER OS', style: AppTheme.displayLarge)),
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(
          index: 1,
          child: QuoteCard(
            quote: quoteFor(QuoteSurface.onboarding, DateTime.now()),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(
          index: 2,
          child: JournalField(
            label: 'What do we call you?',
            controller: controller,
            hint: 'Fighter name, optional',
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _StanceStep extends StatelessWidget {
  const _StanceStep();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      children: [
        const SettleIn(child: Text('YOUR STANCE', style: AppTheme.label)),
        const SizedBox(height: AppTheme.spaceSm),
        const SettleIn(
          child: Text('Which foot is forward?', style: AppTheme.displayMedium),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        for (final stance in Stance.values) ...[
          if (stance != Stance.values.first)
            const SizedBox(height: AppTheme.spaceMd),
          SettleIn(
            index: stance.index + 1,
            child: _ChoiceCard(
              title: stance.label,
              description: _stanceDescription(stance),
              isSelected: settings.stance == stance,
              onTap: () => settings.setStance(stance),
            ),
          ),
        ],
      ],
    );
  }
}

class _LevelStep extends StatelessWidget {
  const _LevelStep();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      children: [
        const SettleIn(child: Text('YOUR LEVEL', style: AppTheme.label)),
        const SizedBox(height: AppTheme.spaceSm),
        const SettleIn(
          child: Text('How far along are you?', style: AppTheme.displayMedium),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        for (final level in Difficulty.values) ...[
          if (level != Difficulty.values.first)
            const SizedBox(height: AppTheme.spaceMd),
          SettleIn(
            index: level.index + 1,
            child: _ChoiceCard(
              title: level.label,
              description: _levelDescription(level),
              isSelected: settings.difficulty == level,
              onTap: () => settings.setDifficulty(level),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  static const double _minHeight = 112;
  static const double _selectedBorder = 2;

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLg);
    return Material(
      color: AppTheme.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.line,
              width: isSelected ? _selectedBorder : AppTheme.hairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppTheme.displaySmall),
              const SizedBox(height: AppTheme.spaceSm),
              Text(description, style: AppTheme.bodyMuted),
            ],
          ),
        ),
      ),
    );
  }
}

String _stanceDescription(Stance stance) => switch (stance) {
  Stance.orthodox => 'Left foot forward. Jab with the left.',
  Stance.southpaw => 'Right foot forward. Jab with the right.',
};

String _levelDescription(Difficulty level) => switch (level) {
  Difficulty.beginner => 'New to boxing or under a year in.',
  Difficulty.intermediate => 'Comfortable with the basics, sparring sometimes.',
  Difficulty.advanced => 'Competing or coaching-level fundamentals.',
};
