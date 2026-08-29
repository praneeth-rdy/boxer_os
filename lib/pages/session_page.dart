import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_event.dart';
import '../models/session_phase.dart';
import '../providers/session_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/cue_banner.dart';
import '../widgets/pill_button.dart';
import '../widgets/round_clock.dart';
import 'session_complete_page.dart';

/// The phone-down session screen: countdown, cue and glove-sized controls.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  static const double _pausedSlot = 48;
  static const double _pausedAlpha = 0.5;
  static const double _flashAlpha = 0.22;

  bool _isLeaving = false;
  bool _isFlashing = false;
  Color _flashColor = AppTheme.accent;
  StreamSubscription<SessionEvent>? _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<SessionProvider>().events.listen(_flashPhaseChange);
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        if (session.phase == SessionPhase.complete) _leaveForSummary();
        return PopScope(
          canPop: !session.isActive,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmEnd(session);
          },
          child: Scaffold(
            backgroundColor: AppTheme.ink,
            body: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _eyebrow(session),
                                style: AppTheme.label,
                              ),
                            ),
                            Text(
                              session.workout?.name ?? '',
                              style: AppTheme.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        Text(
                          _phaseWord(session.phase),
                          style: AppTheme.displaySmall.copyWith(
                            color: RoundClock.colorFor(session.phase),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: session.isActive
                                ? session.togglePause
                                : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: _pausedSlot,
                                  child: Center(
                                    child: _paused(session.isPaused),
                                  ),
                                ),
                                Opacity(
                                  opacity: session.isPaused ? _pausedAlpha : 1,
                                  child: RoundClock(
                                    secondsLeft: session.secondsLeft,
                                    phaseSeconds: session.phaseSeconds,
                                    phase: session.phase,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceLg),
                                CueBanner(
                                  cue: session.currentCue,
                                  fallback: _focus(session),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PillButton(
                          label: session.isPaused ? 'Resume' : 'Pause',
                          style: session.isPaused
                              ? PillStyle.outlined
                              : PillStyle.filled,
                          height: AppTheme.sessionTapTarget,
                          onPressed: session.togglePause,
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Row(
                          children: [
                            Expanded(
                              child: PillButton(
                                label: 'Skip',
                                style: PillStyle.ghost,
                                height: AppTheme.sessionTapTarget,
                                onPressed: session.skipPhase,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
                            Expanded(
                              child: PillButton(
                                label: 'End',
                                style: PillStyle.outlined,
                                height: AppTheme.sessionTapTarget,
                                onPressed: () => _confirmEnd(session),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      // The wash lands on the frame the phase turns over; only
                      // the fade back out is animated.
                      opacity: _isFlashing ? _flashAlpha : 0,
                      duration: _isFlashing ? Duration.zero : AppMotion.flash,
                      curve: AppMotion.change,
                      child: ColoredBox(color: _flashColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The label fades in and out, and leaves the tree once it has gone.
  Widget _paused(bool isPaused) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isPaused ? 1 : 0),
    duration: AppMotion.of(context, AppMotion.fast),
    curve: AppMotion.change,
    builder: (context, opacity, child) => isPaused || opacity > 0
        ? Opacity(opacity: opacity, child: child)
        : const SizedBox.shrink(),
    child: Text(
      'PAUSED',
      style: AppTheme.displayMedium.copyWith(color: AppTheme.chalkMuted),
    ),
  );

  /// A phase change is washed over the whole screen in its own colour, so it
  /// reads from across the gym.
  void _flashPhaseChange(SessionEvent event) {
    final color = switch (event.type) {
      SessionEventType.roundStarted => RoundClock.colorFor(SessionPhase.work),
      SessionEventType.restStarted => RoundClock.colorFor(SessionPhase.rest),
      _ => null,
    };
    if (color == null || !mounted || AppMotion.reduced(context)) return;
    setState(() {
      _flashColor = color;
      _isFlashing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isFlashing = false);
    });
  }

  String _eyebrow(SessionProvider session) => switch (session.phase) {
    SessionPhase.prepare => 'GET READY',
    SessionPhase.work || SessionPhase.rest =>
      'ROUND ${session.round} OF ${session.workout?.roundCount ?? 0}',
    SessionPhase.complete => 'COMPLETE',
    SessionPhase.idle => 'SESSION',
  };

  String _phaseWord(SessionPhase phase) => switch (phase) {
    SessionPhase.prepare => 'PREPARE',
    SessionPhase.work => 'WORK',
    SessionPhase.rest => 'REST',
    SessionPhase.idle || SessionPhase.complete => '',
  };

  String _focus(SessionProvider session) {
    final workout = session.workout;
    if (workout == null ||
        session.round < 1 ||
        session.round > workout.roundCount) {
      return 'Free round';
    }
    final focus = workout.rounds[session.round - 1].focus;
    return focus.isEmpty ? 'Free round' : focus;
  }

  Future<void> _confirmEnd(SessionProvider session) async {
    if (_isLeaving) return;
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceRaised,
        title: const Text('End session?', style: AppTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep going', style: AppTheme.bodyStrong),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'End',
              style: AppTheme.bodyStrong.copyWith(color: AppTheme.accent),
            ),
          ),
        ],
      ),
    );
    if (shouldEnd ?? false) session.end();
  }

  void _leaveForSummary() {
    if (_isLeaving) return;
    _isLeaving = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SessionCompletePage()),
      );
    });
  }
}
