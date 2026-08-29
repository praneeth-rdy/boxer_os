import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/combination_library.dart';
import '../models/combination.dart';
import '../models/combo_tag.dart';
import '../models/difficulty.dart';
import '../models/workout.dart';
import '../providers/combos_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/combination_generator.dart';
import '../utils/duration_format.dart';
import '../utils/practice_builder.dart';
import '../utils/session_launcher.dart';
import '../widgets/combo_sheet.dart';
import '../widgets/combo_tile.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_header.dart';
import '../widgets/stepper_row.dart';

const int _seedRange = 0xFFFF;
const int _minRounds = 1;
const int _maxRounds = 12;
const int _minRoundSeconds = 60;
const int _maxRoundSeconds = 300;
const int _roundSecondsStep = 30;
const double _actionHeight = 56;
const double _bookmarkIconSize = 22;

/// Which of the three combination views the page is showing.
enum ComboView {
  generate,
  library,
  saved;

  String get label => switch (this) {
    ComboView.generate => 'Generate',
    ComboView.library => 'Library',
    ComboView.saved => 'Saved',
  };
}

/// The combination lab: generate, browse the library and drill what is saved.
class CombosPage extends StatefulWidget {
  const CombosPage({super.key});

  @override
  State<CombosPage> createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  final Random _random = Random();

  ComboView view = ComboView.generate;
  late Difficulty difficulty;
  Difficulty? libraryDifficulty;
  ComboTag? libraryTag;
  late int seed;
  int practiceRounds = 3;
  int practiceRoundSeconds = 120;

  @override
  void initState() {
    super.initState();
    difficulty = context.read<SettingsProvider>().difficulty;
    libraryDifficulty = difficulty;
    seed = _random.nextInt(_seedRange);
  }

  Combination get combination =>
      generateCombination(difficulty: difficulty, seed: seed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          const SectionHeader(title: 'Combos', eyebrow: 'COMBINATION LAB'),
          SegmentedButton<ComboView>(
            segments: [
              for (final option in ComboView.values)
                ButtonSegment<ComboView>(
                  value: option,
                  label: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            selected: {view},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => _showView(selection.first),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          switch (view) {
            ComboView.generate => _GenerateView(
              difficulty: difficulty,
              combination: combination,
              rounds: practiceRounds,
              roundSeconds: practiceRoundSeconds,
              onDifficultyChanged: _selectDifficulty,
              onReroll: _rerollSeed,
              onRoundsChanged: _setRounds,
              onRoundSecondsChanged: _setRoundSeconds,
              onStart: () => startSession(context, _generatedPractice()),
            ),
            ComboView.library => _LibraryView(
              difficulty: libraryDifficulty,
              tag: libraryTag,
              onDifficultyChanged: (level) =>
                  setState(() => libraryDifficulty = level),
              onTagChanged: (tag) => setState(() => libraryTag = tag),
            ),
            ComboView.saved => _SavedView(
              rounds: practiceRounds,
              roundSeconds: practiceRoundSeconds,
              onRoundsChanged: _setRounds,
              onRoundSecondsChanged: _setRoundSeconds,
              onBrowseLibrary: () => _showView(ComboView.library),
              onStart: () => startSession(context, _savedPractice()),
            ),
          },
        ],
      ),
    );
  }

  void _showView(ComboView selected) => setState(() => view = selected);

  void _setRounds(int rounds) => setState(() => practiceRounds = rounds);

  void _setRoundSeconds(int seconds) =>
      setState(() => practiceRoundSeconds = seconds);

  void _selectDifficulty(Difficulty selected) {
    setState(() => difficulty = selected);
    context.read<SettingsProvider>().setDifficulty(selected);
  }

  void _rerollSeed() => setState(() => seed = _random.nextInt(_seedRange));

  /// Enough fresh combinations that the whole drill calls each one once.
  Workout _generatedPractice() => buildPracticeWorkout(
    combinations: generateCombinationSet(
      difficulty: difficulty,
      seed: seed,
      count: practiceCuesPerRound(practiceRoundSeconds) * practiceRounds,
    ),
    rounds: practiceRounds,
    roundSeconds: practiceRoundSeconds,
    difficulty: difficulty,
  );

  Workout _savedPractice() => buildPracticeWorkout(
    combinations: context.read<CombosProvider>().saved,
    rounds: practiceRounds,
    roundSeconds: practiceRoundSeconds,
    difficulty: context.read<SettingsProvider>().difficulty,
  );
}

class _GenerateView extends StatelessWidget {
  const _GenerateView({
    required this.difficulty,
    required this.combination,
    required this.rounds,
    required this.roundSeconds,
    required this.onDifficultyChanged,
    required this.onReroll,
    required this.onRoundsChanged,
    required this.onRoundSecondsChanged,
    required this.onStart,
  });

  final Difficulty difficulty;
  final Combination combination;
  final int rounds;
  final int roundSeconds;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final VoidCallback onReroll;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onRoundSecondsChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<Difficulty>(
          segments: [
            for (final level in Difficulty.values)
              ButtonSegment<Difficulty>(
                value: level,
                label: Text(
                  level.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          selected: {difficulty},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              onDifficultyChanged(selection.first),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        _CombinationCard(combination: combination),
        const SizedBox(height: AppTheme.spaceMd),
        PillButton(
          label: 'New combo',
          onPressed: onReroll,
          height: _actionHeight,
        ),
        const SizedBox(height: AppTheme.spaceXl),
        _PracticeSection(
          rounds: rounds,
          roundSeconds: roundSeconds,
          onRoundsChanged: onRoundsChanged,
          onRoundSecondsChanged: onRoundSecondsChanged,
          onStart: onStart,
        ),
      ],
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView({
    required this.difficulty,
    required this.tag,
    required this.onDifficultyChanged,
    required this.onTagChanged,
  });

  final Difficulty? difficulty;
  final ComboTag? tag;
  final ValueChanged<Difficulty?> onDifficultyChanged;
  final ValueChanged<ComboTag?> onTagChanged;

  @override
  Widget build(BuildContext context) {
    final combos = context.watch<CombosProvider>();
    final matches = combinationsWhere(difficulty: difficulty, tag: tag);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChipRow<Difficulty>(
          values: Difficulty.values,
          selected: difficulty,
          label: (level) => level.label,
          onSelected: onDifficultyChanged,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        FilterChipRow<ComboTag>(
          values: ComboTag.values,
          selected: tag,
          label: (value) => value.label,
          onSelected: onTagChanged,
        ),
        const SizedBox(height: AppTheme.spaceLg),
        if (matches.isEmpty)
          const Text(
            'Nothing matches those filters.',
            style: AppTheme.bodyMuted,
          ),
        for (final combination in matches) ...[
          ComboTile(
            combination: combination,
            isSaved: combos.isSaved(combination),
            onTap: () => showComboSheet(context, combination),
            onToggleSaved: () => combos.toggleSaved(combination),
          ),
          const SizedBox(height: AppTheme.spaceSm),
        ],
      ],
    );
  }
}

class _SavedView extends StatelessWidget {
  const _SavedView({
    required this.rounds,
    required this.roundSeconds,
    required this.onRoundsChanged,
    required this.onRoundSecondsChanged,
    required this.onBrowseLibrary,
    required this.onStart,
  });

  final int rounds;
  final int roundSeconds;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onRoundSecondsChanged;
  final VoidCallback onBrowseLibrary;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final combos = context.watch<CombosProvider>();
    final saved = combos.saved;
    if (saved.isEmpty) {
      return _EmptySaved(onBrowseLibrary: onBrowseLibrary);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final combination in saved) ...[
          ComboTile(
            combination: combination,
            isSaved: true,
            onTap: () => showComboSheet(context, combination),
            onToggleSaved: () => combos.remove(combination),
          ),
          const SizedBox(height: AppTheme.spaceSm),
        ],
        const SizedBox(height: AppTheme.spaceLg),
        _PracticeSection(
          rounds: rounds,
          roundSeconds: roundSeconds,
          onRoundsChanged: onRoundsChanged,
          onRoundSecondsChanged: onRoundSecondsChanged,
          onStart: onStart,
          startLabel: 'Practice saved',
          startStyle: PillStyle.filled,
        ),
      ],
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved({required this.onBrowseLibrary});

  final VoidCallback onBrowseLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOTHING SAVED YET', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        const Text(
          'Bookmark the ones you want to drill',
          style: AppTheme.displayMedium,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        const Text(
          'Tap the bookmark on any combination. Saved combos become a '
          'practice session here.',
          style: AppTheme.bodyMuted,
        ),
        const SizedBox(height: AppTheme.spaceLg),
        PillButton(
          label: 'Browse the library',
          onPressed: onBrowseLibrary,
          style: PillStyle.ghost,
          height: _actionHeight,
        ),
      ],
    );
  }
}

class _CombinationCard extends StatelessWidget {
  const _CombinationCard({required this.combination});

  final Combination combination;

  static const double _minHeight = 200;

  @override
  Widget build(BuildContext context) {
    final combos = context.watch<CombosProvider>();
    final isSaved = combos.isSaved(combination);
    final seedLabel = combination.seed
        .toRadixString(16)
        .toUpperCase()
        .padLeft(4, '0');

    return Stack(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  combination.notation,
                  style: AppTheme.displayLarge,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                combination.spoken,
                style: AppTheme.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text('#$seedLabel', style: AppTheme.caption),
            ],
          ),
        ),
        Positioned(
          top: AppTheme.spaceSm,
          right: AppTheme.spaceSm,
          child: IconButton(
            onPressed: () => combos.toggleSaved(combination),
            iconSize: _bookmarkIconSize,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppTheme.accent : AppTheme.chalkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _PracticeSection extends StatelessWidget {
  const _PracticeSection({
    required this.rounds,
    required this.roundSeconds,
    required this.onRoundsChanged,
    required this.onRoundSecondsChanged,
    required this.onStart,
    this.startLabel = 'Start practice',
    this.startStyle = PillStyle.outlined,
  });

  final int rounds;
  final int roundSeconds;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onRoundSecondsChanged;
  final VoidCallback onStart;
  final String startLabel;
  final PillStyle startStyle;

  @override
  Widget build(BuildContext context) {
    final roundWord = rounds == 1 ? 'round' : 'rounds';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRACTICE', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        StepperRow(
          label: 'Rounds',
          value: '$rounds',
          onDecrement: rounds > _minRounds
              ? () => onRoundsChanged(rounds - 1)
              : null,
          onIncrement: rounds < _maxRounds
              ? () => onRoundsChanged(rounds + 1)
              : null,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        StepperRow(
          label: 'Round length',
          value: formatClock(roundSeconds),
          onDecrement: roundSeconds > _minRoundSeconds
              ? () => onRoundSecondsChanged(roundSeconds - _roundSecondsStep)
              : null,
          onIncrement: roundSeconds < _maxRoundSeconds
              ? () => onRoundSecondsChanged(roundSeconds + _roundSecondsStep)
              : null,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Text(
          '$rounds $roundWord, a new combination every '
          '$practiceCueInterval seconds',
          style: AppTheme.bodyMuted,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        PillButton(
          label: startLabel,
          onPressed: onStart,
          style: startStyle,
          height: _actionHeight,
        ),
      ],
    );
  }
}
