import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/defense_zone.dart';
import '../models/incoming_punch.dart';
import '../models/reaction_direction.dart';
import '../models/reaction_format.dart';
import '../models/reaction_mode.dart';
import '../models/reaction_result.dart';
import '../models/stance.dart';

/// Where a reaction test currently is.
enum ReactionPhase { idle, countdown, waiting, stimulus, feedback, complete }

/// Runs a reaction test on one timer at a time, ten trials or a timed minute.
class ReactionProvider extends ChangeNotifier {
  ReactionProvider({DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random();

  static const int trialCount = 10;
  static const int enduranceSeconds = 60;

  static const int _countdownStart = 3;
  static const int _minWaitMillis = 1500;
  static const int _waitSpreadMillis = 2500;
  static const int _stimulusTimeoutMillis = 2000;
  static const int _holdMillis = 1000;
  static const int _feedbackMillis = 700;
  static const double _goChance = 0.7;

  final DateTime Function() _clock;
  final Random _random;
  final List<int> _reactionMillis = [];

  Timer? _timer;
  ReactionMode _mode = ReactionMode.tap;
  ReactionFormat _format = ReactionFormat.standard;
  Stance _stance = Stance.orthodox;
  ReactionPhase _phase = ReactionPhase.idle;
  int _trial = 0;
  int _countdownSeconds = 0;
  ReactionDirection? _direction;
  IncomingPunch? _incomingPunch;
  bool _isGo = true;
  int? _lastMillis;
  String? _feedback;
  int _falseStarts = 0;
  int _misses = 0;
  int _correctHolds = 0;
  int _falseAlarms = 0;
  ReactionResult? _result;
  DateTime _shownAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _firstStimulusAt;
  DateTime? _lastResponseAt;

  ReactionMode get mode => _mode;
  ReactionFormat get format => _format;
  Stance get stance => _stance;
  ReactionPhase get phase => _phase;

  /// 1-based trial, 0 while idle.
  int get trial => _trial;

  /// Seconds left of the lead-in, 3 down to 1.
  int get countdownSeconds => _countdownSeconds;

  /// The edge to hit, set on the stimulus in direction mode only.
  ReactionDirection? get direction => _direction;

  /// The punch to answer, set on the stimulus in defense mode only.
  IncomingPunch? get incomingPunch => _incomingPunch;

  /// Whether the live stimulus asks for a tap; always true outside go / no-go.
  bool get isGo => _isGo;

  /// Whole seconds left of an endurance run, 0 in the standard format.
  int get secondsLeft {
    final startedAt = _firstStimulusAt;
    if (_format != ReactionFormat.endurance) {
      return 0;
    }
    if (startedAt == null) {
      return enduranceSeconds;
    }
    final elapsed = _clock().difference(startedAt).inSeconds;
    return (enduranceSeconds - elapsed).clamp(0, enduranceSeconds);
  }

  /// Reaction time of the last hit, null until one lands.
  int? get lastMillis => _lastMillis;

  /// What the arena shows during [ReactionPhase.feedback].
  String? get feedback => _feedback;

  int get falseStarts => _falseStarts;
  int get misses => _misses;
  int get correctHolds => _correctHolds;
  int get falseAlarms => _falseAlarms;

  /// Built when the run finishes, null otherwise.
  ReactionResult? get result => _result;

  void start(
    ReactionMode mode, {
    ReactionFormat format = ReactionFormat.standard,
    Stance stance = Stance.orthodox,
  }) {
    _timer?.cancel();
    _mode = mode;
    _format = format;
    _stance = stance;
    _phase = ReactionPhase.countdown;
    _trial = 1;
    _countdownSeconds = _countdownStart;
    _resetRun();
    _timer = Timer.periodic(const Duration(seconds: 1), _tickCountdown);
    notifyListeners();
  }

  void tap({ReactionDirection? direction, DefenseZone? defense}) {
    switch (_phase) {
      case ReactionPhase.waiting:
        _falseStarts++;
        _enterFeedback('Early!', consumesTrial: false);
      case ReactionPhase.stimulus:
        _recordTap(direction, defense);
      case ReactionPhase.idle:
      case ReactionPhase.countdown:
      case ReactionPhase.feedback:
      case ReactionPhase.complete:
        return;
    }
    notifyListeners();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _phase = ReactionPhase.idle;
    _trial = 0;
    _countdownSeconds = 0;
    _resetRun();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _resetRun() {
    _direction = null;
    _incomingPunch = null;
    _isGo = true;
    _lastMillis = null;
    _feedback = null;
    _falseStarts = 0;
    _misses = 0;
    _correctHolds = 0;
    _falseAlarms = 0;
    _reactionMillis.clear();
    _result = null;
    _firstStimulusAt = null;
    _lastResponseAt = null;
  }

  void _tickCountdown(Timer timer) {
    _countdownSeconds--;
    if (_countdownSeconds <= 0) {
      timer.cancel();
      _timer = null;
      _beginWait();
    }
    notifyListeners();
  }

  void _beginWait() {
    _phase = ReactionPhase.waiting;
    _direction = null;
    _incomingPunch = null;
    _feedback = null;
    _schedule(
      _minWaitMillis + _random.nextInt(_waitSpreadMillis),
      _showStimulus,
    );
  }

  void _showStimulus() {
    _phase = ReactionPhase.stimulus;
    _shownAt = _clock();
    _firstStimulusAt ??= _shownAt;
    _direction = _mode == ReactionMode.direction
        ? ReactionDirection.values[_random.nextInt(
            ReactionDirection.values.length,
          )]
        : null;
    _incomingPunch = _mode == ReactionMode.defense
        ? IncomingPunch.values[_random.nextInt(IncomingPunch.values.length)]
        : null;
    _isGo = _mode != ReactionMode.goNoGo || _random.nextDouble() < _goChance;
    if (_isGo) {
      _schedule(_stimulusTimeoutMillis, _missTrial);
      return;
    }
    _schedule(_holdMillis, _holdTrial);
  }

  void _recordTap(ReactionDirection? direction, DefenseZone? defense) {
    if (!_isGo) {
      _falseAlarms++;
      _enterFeedback('Hold!', consumesTrial: true);
      return;
    }
    final edge = _direction;
    if (edge != null && direction != edge) {
      _misses++;
      _enterFeedback('Wrong side', consumesTrial: true);
      return;
    }
    final punch = _incomingPunch;
    if (punch != null && defense != defenseFor(punch, _stance)) {
      _misses++;
      _enterFeedback('Wrong defense', consumesTrial: true);
      return;
    }
    final millis = _clock().difference(_shownAt).inMilliseconds;
    _reactionMillis.add(millis);
    _lastMillis = millis;
    _enterFeedback('$millis ms', consumesTrial: true);
  }

  void _missTrial() {
    _misses++;
    _enterFeedback('Too slow', consumesTrial: true);
  }

  void _holdTrial() {
    _correctHolds++;
    _enterFeedback('Good hold', consumesTrial: true);
  }

  void _enterFeedback(String text, {required bool consumesTrial}) {
    _phase = ReactionPhase.feedback;
    _feedback = text;
    if (consumesTrial) {
      _lastResponseAt = _clock();
    }
    _schedule(_feedbackMillis, consumesTrial ? _finishTrial : _beginWait);
  }

  void _finishTrial() {
    if (_isRunOver) {
      _complete();
      return;
    }
    _trial++;
    _beginWait();
  }

  /// Endurance runs to the minute, so it ends within one trial of it.
  bool get _isRunOver {
    if (_format != ReactionFormat.endurance) {
      return _trial >= trialCount;
    }
    final startedAt = _firstStimulusAt;
    return startedAt != null &&
        _clock().difference(startedAt) >=
            const Duration(seconds: enduranceSeconds);
  }

  void _complete() {
    _phase = ReactionPhase.complete;
    _direction = null;
    _incomingPunch = null;
    _feedback = null;
    _result = ReactionResult(
      mode: _mode,
      format: _format,
      completedAt: _clock(),
      reactionMillis: List<int>.unmodifiable(_reactionMillis),
      falseStarts: _falseStarts,
      misses: _misses,
      correctHolds: _correctHolds,
      falseAlarms: _falseAlarms,
      durationSeconds: _durationSeconds,
    );
  }

  int get _durationSeconds {
    if (_format == ReactionFormat.endurance) {
      return enduranceSeconds;
    }
    final startedAt = _firstStimulusAt;
    final endedAt = _lastResponseAt;
    if (startedAt == null || endedAt == null) {
      return 0;
    }
    final millis = endedAt.difference(startedAt).inMilliseconds;
    return (millis / Duration.millisecondsPerSecond).round();
  }

  /// Only one timer runs at a time, so every transition replaces the last.
  void _schedule(int millis, VoidCallback onElapsed) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: millis), () {
      _timer = null;
      onElapsed();
      notifyListeners();
    });
  }
}
