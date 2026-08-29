import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/difficulty.dart';
import '../models/round_spec.dart';
import '../models/session_event.dart';
import '../models/session_phase.dart';
import '../models/session_record.dart';
import '../models/stance.dart';
import '../models/workout.dart';

/// Runs a [Workout] through its prepare, work and rest phases on one timer.
class SessionProvider extends ChangeNotifier {
  SessionProvider({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final StreamController<SessionEvent> _events =
      StreamController<SessionEvent>.broadcast();

  Timer? _timer;
  Workout? _workout;
  SessionPhase _phase = SessionPhase.idle;
  int _round = 0;
  int _secondsLeft = 0;
  int _phaseSeconds = 0;
  bool _isPaused = false;
  String? _currentCue;
  int _roundsCompleted = 0;
  Stance _stance = Stance.orthodox;
  Difficulty _difficulty = Difficulty.beginner;
  SessionRecord? _record;

  Duration _elapsed = Duration.zero;
  DateTime _startedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _phaseStartedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTickAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool _finalThirtyFired = false;
  bool _tenSecondWarningFired = false;
  int _nextCueIndex = 0;

  Workout? get workout => _workout;
  SessionPhase get phase => _phase;

  /// 1-based round, 0 while idle, the last round once complete.
  int get round => _round;

  int get secondsLeft => _secondsLeft;

  /// Length of the current phase, for progress indicators.
  int get phaseSeconds => _phaseSeconds;

  bool get isPaused => _isPaused;

  bool get isActive =>
      _phase == SessionPhase.prepare ||
      _phase == SessionPhase.work ||
      _phase == SessionPhase.rest;

  /// Latest cue of the current round, null until one fires.
  String? get currentCue => _currentCue;

  /// Training time so far, pauses excluded.
  int get elapsedSeconds => _elapsed.inSeconds;

  int get roundsCompleted => _roundsCompleted;
  Stance get stance => _stance;
  Difficulty get difficulty => _difficulty;

  /// Built when the session completes or is ended early, null otherwise.
  SessionRecord? get record => _record;

  Stream<SessionEvent> get events => _events.stream;

  void start(
    Workout workout, {
    required Stance stance,
    required Difficulty difficulty,
  }) {
    if (workout.rounds.isEmpty) return;
    if (isActive) end();

    _timer?.cancel();
    _workout = workout;
    _stance = stance;
    _difficulty = difficulty;
    _record = null;
    _roundsCompleted = 0;
    _elapsed = Duration.zero;
    _isPaused = false;
    _currentCue = null;
    _round = 1;

    final now = _clock();
    _startedAt = now;
    _lastTickAt = now;
    if (workout.prepareSeconds > 0) {
      _enterPhase(SessionPhase.prepare, workout.prepareSeconds, now);
      _emit(SessionEventType.prepareStarted);
    } else {
      _startRound(workout, 1, now);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pause() {
    if (!isActive || _isPaused) return;
    final now = _clock();
    _elapsed += now.difference(_lastTickAt);
    _lastTickAt = now;
    _secondsLeft = _remainingAt(now);
    _isPaused = true;
    _emit(SessionEventType.paused);
    notifyListeners();
  }

  void resume() {
    if (!isActive || !_isPaused) return;
    final now = _clock();
    _lastTickAt = now;
    // Move the deadline instead of shortening the phase, so progress holds.
    _phaseStartedAt = now.subtract(
      Duration(seconds: _phaseSeconds - _secondsLeft),
    );
    _isPaused = false;
    _emit(SessionEventType.resumed);
    notifyListeners();
  }

  void togglePause() => _isPaused ? resume() : pause();

  /// Ends the current phase early; a skipped work round does not count.
  void skipPhase() {
    final workout = _workout;
    if (!isActive || workout == null) return;
    final now = _clock();
    _emit(SessionEventType.roundSkipped);
    switch (_phase) {
      case SessionPhase.prepare:
        _startRound(workout, 1, now);
      case SessionPhase.work:
        _leaveWorkPhase(workout, now);
      case SessionPhase.rest:
        _startRound(workout, _round + 1, now);
      case SessionPhase.idle:
      case SessionPhase.complete:
        break;
    }
    notifyListeners();
  }

  void end() {
    if (!isActive) return;
    _finish(completed: false);
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _workout = null;
    _phase = SessionPhase.idle;
    _round = 0;
    _secondsLeft = 0;
    _phaseSeconds = 0;
    _isPaused = false;
    _currentCue = null;
    _roundsCompleted = 0;
    _record = null;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _events.close();
    super.dispose();
  }

  void _tick(Timer timer) {
    final now = _clock();
    final sinceLastTick = now.difference(_lastTickAt);
    _lastTickAt = now;
    final workout = _workout;
    if (_isPaused || !isActive || workout == null) return;

    _elapsed += sinceLastTick;
    _secondsLeft = _remainingAt(now);
    if (_phase == SessionPhase.work) _fireWorkMarks();
    while (_secondsLeft <= 0 && isActive) {
      _advancePhase(workout, now);
    }
    notifyListeners();
  }

  int _remainingAt(DateTime now) {
    final gone = now.difference(_phaseStartedAt).inSeconds;
    return (_phaseSeconds - gone).clamp(0, _phaseSeconds);
  }

  void _advancePhase(Workout workout, DateTime now) {
    switch (_phase) {
      case SessionPhase.prepare:
        _startRound(workout, 1, now);
      case SessionPhase.work:
        _roundsCompleted++;
        _leaveWorkPhase(workout, now);
      case SessionPhase.rest:
        _startRound(workout, _round + 1, now);
      case SessionPhase.idle:
      case SessionPhase.complete:
        break;
    }
  }

  void _leaveWorkPhase(Workout workout, DateTime now) {
    if (_round >= workout.rounds.length) {
      _finish(completed: true);
      return;
    }
    final restSeconds = workout.rounds[_round - 1].restSeconds;
    if (restSeconds > 0) {
      _currentCue = null;
      _enterPhase(SessionPhase.rest, restSeconds, now);
      _emit(SessionEventType.restStarted);
    } else {
      _startRound(workout, _round + 1, now);
    }
  }

  void _startRound(Workout workout, int round, DateTime now) {
    _round = round;
    _currentCue = null;
    _finalThirtyFired = false;
    _tenSecondWarningFired = false;
    _nextCueIndex = 0;
    _enterPhase(SessionPhase.work, workout.rounds[round - 1].workSeconds, now);
    _emit(SessionEventType.roundStarted);
  }

  void _enterPhase(SessionPhase phase, int seconds, DateTime now) {
    _phase = phase;
    _phaseSeconds = seconds;
    _phaseStartedAt = now;
    _secondsLeft = seconds;
  }

  /// Fires the warnings and every cue the round has passed, in order, once each.
  void _fireWorkMarks() {
    final round = _currentRound;
    if (round == null) return;
    if (!_finalThirtyFired && round.workSeconds > 45 && _secondsLeft <= 30) {
      _finalThirtyFired = true;
      _emit(SessionEventType.finalThirty);
    }
    if (!_tenSecondWarningFired &&
        round.workSeconds > 20 &&
        _secondsLeft <= 10) {
      _tenSecondWarningFired = true;
      _emit(SessionEventType.tenSecondWarning);
    }
    final elapsedInRound = round.workSeconds - _secondsLeft;
    while (_nextCueIndex < round.cues.length &&
        round.cues[_nextCueIndex].atSecond <= elapsedInRound) {
      final cue = round.cues[_nextCueIndex];
      _nextCueIndex++;
      _currentCue = cue.text;
      _emit(SessionEventType.cue, cueText: cue.text);
    }
  }

  RoundSpec? get _currentRound {
    final workout = _workout;
    if (workout == null || _round < 1 || _round > workout.rounds.length) {
      return null;
    }
    return workout.rounds[_round - 1];
  }

  void _finish({required bool completed}) {
    _timer?.cancel();
    _timer = null;
    _phase = SessionPhase.complete;
    _secondsLeft = 0;
    _phaseSeconds = 0;
    _isPaused = false;
    _record = _buildRecord(completed: completed);
    _emit(
      completed
          ? SessionEventType.sessionCompleted
          : SessionEventType.sessionEnded,
    );
  }

  SessionRecord? _buildRecord({required bool completed}) {
    final workout = _workout;
    if (workout == null) return null;
    return SessionRecord(
      id: _startedAt.millisecondsSinceEpoch.toString(),
      workoutId: workout.id,
      workoutName: workout.name,
      type: workout.type,
      difficulty: workout.difficulty,
      stance: _stance,
      startedAt: _startedAt,
      durationSeconds: _elapsed.inSeconds,
      roundsCompleted: _roundsCompleted,
      roundsPlanned: workout.roundCount,
      // A session can run to its end with rounds skipped, which is not complete.
      completed: completed && _roundsCompleted >= workout.roundCount,
    );
  }

  void _emit(SessionEventType type, {String? cueText}) {
    if (_events.isClosed) return;
    _events.add(SessionEvent(type, round: _round, cueText: cueText));
  }
}
