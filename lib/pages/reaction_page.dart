import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reaction_format.dart';
import '../models/reaction_mode.dart';
import '../models/reaction_result.dart';
import '../models/stance.dart';
import '../providers/history_provider.dart';
import '../providers/reaction_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_button.dart';
import '../widgets/reaction_arena.dart';
import '../widgets/section_header.dart';
import '../widgets/skill_card.dart';

const double _actionHeight = 56;

/// The reaction trainer: pick a mode and a format, run the test, read the result.
class ReactionPage extends StatefulWidget {
  const ReactionPage({super.key});

  @override
  State<ReactionPage> createState() => _ReactionPageState();
}

class _ReactionPageState extends State<ReactionPage> {
  late final ReactionProvider _reaction;
  late final HistoryProvider _history;
  late final AudioService _audio;

  ReactionFormat _format = ReactionFormat.standard;

  /// The result already stored, so a rebuild cannot save it twice.
  DateTime? _savedAt;

  /// The phase the beep was last judged against, so it fires once per trial.
  ReactionPhase _cuedPhase = ReactionPhase.idle;

  @override
  void initState() {
    super.initState();
    _reaction = context.read<ReactionProvider>();
    _history = context.read<HistoryProvider>();
    _audio = context.read<AudioService>();
    _reaction.addListener(_onReactionChanged);
  }

  @override
  void dispose() {
    _reaction.removeListener(_onReactionChanged);
    if (_isRunning(_reaction.phase)) {
      // The tree is locked while this page unmounts, so notify after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _reaction.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stance = context.watch<SettingsProvider>().stance;
    return Consumer<ReactionProvider>(
      builder: (context, reaction, _) {
        final isRunning = _isRunning(reaction.phase);
        return PopScope(
          canPop: !isRunning,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) reaction.cancel();
          },
          child: Scaffold(
            backgroundColor: AppTheme.ink,
            appBar: isRunning
                ? null
                : AppBar(backgroundColor: Colors.transparent),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: _body(context, reaction, stance),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onReactionChanged() {
    _storeResult();
    _cueSound();
  }

  /// In sound mode the beep is the whole stimulus, so it lands on the change.
  void _cueSound() {
    final phase = _reaction.phase;
    if (phase == _cuedPhase) {
      return;
    }
    _cuedPhase = phase;
    if (phase == ReactionPhase.stimulus && _reaction.isSoundMode) {
      unawaited(_audio.playTick());
    }
  }

  void _storeResult() {
    final result = _reaction.result;
    if (result == null || result.completedAt == _savedAt) {
      return;
    }
    _savedAt = result.completedAt;
    _history.addReaction(result);
  }

  static bool _isRunning(ReactionPhase phase) =>
      phase != ReactionPhase.idle && phase != ReactionPhase.complete;

  Widget _body(BuildContext context, ReactionProvider reaction, Stance stance) {
    final result = reaction.result;
    if (reaction.phase == ReactionPhase.complete && result != null) {
      return _ResultView(
        result: result,
        onAgain: () =>
            reaction.start(result.mode, format: result.format, stance: stance),
        onDone: () {
          reaction.cancel();
          Navigator.of(context).pop();
        },
      );
    }
    if (_isRunning(reaction.phase)) {
      return _RunningView(reaction: reaction);
    }
    return _ModePicker(
      format: _format,
      stance: stance,
      onFormatChanged: (format) => setState(() => _format = format),
      onSelect: (mode) => reaction.start(mode, format: _format, stance: stance),
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({
    required this.format,
    required this.stance,
    required this.onFormatChanged,
    required this.onSelect,
  });

  final ReactionFormat format;
  final Stance stance;
  final void Function(ReactionFormat) onFormatChanged;
  final void Function(ReactionMode) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader(title: 'Reaction', eyebrow: 'REACTION TRAINER'),
        SegmentedButton<ReactionFormat>(
          segments: [
            for (final option in ReactionFormat.values)
              ButtonSegment<ReactionFormat>(
                value: option,
                label: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          selected: {format},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onFormatChanged(selection.first),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        _ModeGroup(
          eyebrow: 'BOXING',
          modes: [
            for (final mode in ReactionMode.values)
              if (mode.isBoxing) mode,
          ],
          onSelect: onSelect,
        ),
        const SizedBox(height: AppTheme.spaceLg),
        _ModeGroup(
          eyebrow: 'PURE SPEED',
          modes: [
            for (final mode in ReactionMode.values)
              if (!mode.isBoxing) mode,
          ],
          onSelect: onSelect,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Text(
          'Defense uses your ${stance.label} stance: slip outside the jab.',
          style: AppTheme.caption,
        ),
      ],
    );
  }
}

/// One eyebrow over the modes that sit under it.
class _ModeGroup extends StatelessWidget {
  const _ModeGroup({
    required this.eyebrow,
    required this.modes,
    required this.onSelect,
  });

  final String eyebrow;
  final List<ReactionMode> modes;
  final void Function(ReactionMode) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(eyebrow, style: AppTheme.label),
        for (final mode in modes) ...[
          const SizedBox(height: AppTheme.spaceMd),
          SkillCard(
            title: mode.label,
            description: mode.description,
            icon: _iconFor(mode),
            onTap: () => onSelect(mode),
          ),
        ],
      ],
    );
  }

  static IconData _iconFor(ReactionMode mode) => switch (mode) {
    ReactionMode.tap => Icons.touch_app_rounded,
    ReactionMode.direction => Icons.open_with_rounded,
    ReactionMode.defense => Icons.shield_rounded,
    ReactionMode.goNoGo => Icons.traffic_rounded,
    ReactionMode.peripheral => Icons.scatter_plot_rounded,
    ReactionMode.colour => Icons.palette_rounded,
    ReactionMode.sequence => Icons.format_list_numbered_rounded,
    ReactionMode.sound => Icons.hearing_rounded,
  };
}

class _RunningView extends StatelessWidget {
  const _RunningView({required this.reaction});

  final ReactionProvider reaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(_progress, style: AppTheme.label)),
            Text(reaction.mode.label.toUpperCase(), style: AppTheme.label),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: ReactionArena(
              reaction: reaction,
              onTap: ({direction, defense, at, colour}) => reaction.tap(
                direction: direction,
                defense: defense,
                at: at,
                colour: colour,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        PillButton(
          label: 'Stop',
          style: PillStyle.ghost,
          height: AppTheme.sessionTapTarget,
          onPressed: reaction.cancel,
        ),
      ],
    );
  }

  String get _progress {
    if (reaction.format == ReactionFormat.endurance) {
      return '${reaction.secondsLeft}s LEFT · TRIAL ${reaction.trial}';
    }
    return 'TRIAL ${reaction.trial} OF ${ReactionProvider.trialCount}';
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.onAgain,
    required this.onDone,
  });

  final ReactionResult result;
  final VoidCallback onAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final showsAccuracy =
        result.mode == ReactionMode.defense ||
        result.mode == ReactionMode.goNoGo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('RESULT', style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceSm),
        Text(result.mode.label, style: AppTheme.displayLarge),
        const SizedBox(height: AppTheme.spaceXl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatCell(value: _millis(result.bestMillis), label: 'Best'),
            _StatCell(value: _millis(result.averageMillis), label: 'Average'),
            if (showsAccuracy)
              _StatCell(value: _percent(result.accuracy), label: 'Accuracy'),
          ],
        ),
        const SizedBox(height: AppTheme.spaceLg),
        if (!showsAccuracy)
          Text(
            '${result.falseStarts} false starts, ${result.misses} misses',
            style: AppTheme.bodyMuted,
          ),
        if (result.format == ReactionFormat.endurance) ...[
          if (!showsAccuracy) const SizedBox(height: AppTheme.spaceSm),
          Text(
            'First half ${_millis(result.firstHalfAverage)} · second half '
            '${_millis(result.secondHalfAverage)}',
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _DecayLine(decayPercent: result.decayPercent),
        ],
        const Spacer(),
        PillButton(label: 'Again', onPressed: onAgain, height: _actionHeight),
        const SizedBox(height: AppTheme.spaceSm),
        PillButton(
          label: 'Done',
          onPressed: onDone,
          style: PillStyle.outlined,
          height: _actionHeight,
        ),
      ],
    );
  }

  static String _millis(int? value) => value == null ? '--' : '$value ms';

  static String _percent(double? value) =>
      value == null ? '--' : '${(value * 100).round()}%';
}

/// How much the endurance run slowed down, or sped up, by the end.
class _DecayLine extends StatelessWidget {
  const _DecayLine({required this.decayPercent});

  final int? decayPercent;

  @override
  Widget build(BuildContext context) {
    final decay = decayPercent;
    if (decay == null) {
      return const Text('No decay data', style: AppTheme.displaySmall);
    }
    final isFaster = decay < 0;
    return Text(
      '${decay.abs()}% ${isFaster ? 'faster' : 'slower'} by the end',
      style: isFaster
          ? AppTheme.displaySmall.copyWith(color: AppTheme.rest)
          : AppTheme.displaySmall,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.displayMedium, maxLines: 1),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(label.toUpperCase(), style: AppTheme.label),
        ],
      ),
    );
  }
}
