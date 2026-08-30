import 'dart:async';
import 'dart:math';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../models/defense_zone.dart';
import '../models/incoming_punch.dart';
import '../models/reaction_colour.dart';
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

  /// How close a peripheral tap must land, in fractions of the arena.
  static const double dotHitRadius = 0.09;

  static const int _countdownStart = 3;
  static const int _minWaitMillis = 1500;
  static const int _waitSpreadMillis = 2500;
  static const int _stimulusTimeoutMillis = 2000;
  static const int _holdMillis = 1000;
  static const int _feedbackMillis = 700;
  static const int _sequenceShowMillis = 600;
  static const double _goChance = 0.7;
  static const double _dotInset = 0.1;
  static const int _minSequence = 2;
  static const int _maxSequence = 4;
  static const int _enduranceSequenceStep = 3;

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
  Offset? _dotPosition;
  ReactionColour _inkColour = ReactionColour.red;
  ReactionColour _wordColour = ReactionColour.mint;
  List<ReactionDirection> _sequence = const [];
  int _entered = 0;
  bool _isShowingSequence = false;
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

  /// Where the dot sits as fractions of the arena, in peripheral mode only.
  Offset? get dotPosition => _dotPosition;

  /// The colour the word is printed in, the answer in colour mode.
  ReactionColour get inkColour => _inkColour;

  /// The colour the word names, never the ink colour.
  ReactionColour get wordColour => _wordColour;

  /// The arrows to tap back, empty outside a live sequence trial.
  List<ReactionDirection> get sequence => _sequence;

  /// How many arrows of [sequence] have been tapped back correctly.
  int get entered => _entered;

  /// Whether the sequence is still on screen, so the clock has not started.
  bool get isShowingSequence => _isShowingSequence;

  /// Whether the stimulus is a beep rather than anything to look at.
  bool get isSoundMode => _mode == ReactionMode.sound;

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

  void tap({
    ReactionDirection? direction,
    DefenseZone? defense,
    Offset? at,
    ReactionColour? colour,
  }) {
    switch (_phase) {
      case ReactionPhase.waiting:
        _falseStarts++;
        _enterFeedback('Early!', consumesTrial: false);
      case ReactionPhase.stimulus:
        // The arrows are still up, so there is nothing to answer yet.
        if (_isShowingSequence) return;
        _recordTap(direction, defense, at, colour);
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
    _clearStimulus();
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

  void _clearStimulus() {
    _direction = null;
    _incomingPunch = null;
    _dotPosition = null;
    _sequence = const [];
    _entered = 0;
    _isShowingSequence = false;
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
    _clearStimulus();
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
    _direction = _mode == ReactionMode.direction ? _randomDirection() : null;
    _incomingPunch = _mode == ReactionMode.defense
        ? IncomingPunch.values[_random.nextInt(IncomingPunch.values.length)]
        : null;
    _dotPosition = _mode == ReactionMode.peripheral ? _randomDot() : null;
    if (_mode == ReactionMode.colour) {
      _pickColours();
    }
    _isGo = _mode != ReactionMode.goNoGo || _random.nextDouble() < _goChance;
    if (_mode == ReactionMode.sequence) {
      _showSequence();
      return;
    }
    if (_isGo) {
      _schedule(_stimulusTimeoutMillis, _missTrial);
      return;
    }
    _schedule(_holdMillis, _holdTrial);
  }

  ReactionDirection _randomDirection() =>
      ReactionDirection.values[_random.nextInt(
        ReactionDirection.values.length,
      )];

  Offset _randomDot() {
    final spread = 1 - _dotInset * 2;
    return Offset(
      _dotInset + _random.nextDouble() * spread,
      _dotInset + _random.nextDouble() * spread,
    );
  }

  void _pickColours() {
    _inkColour =
        ReactionColour.values[_random.nextInt(ReactionColour.values.length)];
    final others = [
      for (final option in ReactionColour.values)
        if (option != _inkColour) option,
    ];
    _wordColour = others[_random.nextInt(others.length)];
  }

  void _showSequence() {
    _sequence = List<ReactionDirection>.generate(
      _sequenceLength,
      (_) => _randomDirection(),
    );
    _entered = 0;
    _isShowingSequence = true;
    _schedule(_sequenceShowMillis * _sequence.length, _hideSequence);
  }

  /// The clock starts only once the arrows are gone.
  void _hideSequence() {
    _isShowingSequence = false;
    _shownAt = _clock();
    _schedule(_stimulusTimeoutMillis * _sequence.length, _missTrial);
  }

  int get _sequenceLength {
    if (_format == ReactionFormat.endurance) {
      final grown = _minSequence + (_trial - 1) ~/ _enduranceSequenceStep;
      return grown.clamp(_minSequence, _maxSequence);
    }
    if (_trial <= 3) {
      return _minSequence;
    }
    return _trial <= 7 ? 3 : _maxSequence;
  }

  void _recordTap(
    ReactionDirection? direction,
    DefenseZone? defense,
    Offset? at,
    ReactionColour? colour,
  ) {
    if (!_isGo) {
      _falseAlarms++;
      _enterFeedback('Hold!', consumesTrial: true);
      return;
    }
    if (_mode == ReactionMode.sequence) {
      _recordSequenceTap(direction);
      return;
    }
    final dot = _dotPosition;
    if (dot != null && (at == null || (at - dot).distance > dotHitRadius)) {
      _misses++;
      _enterFeedback('Missed it', consumesTrial: true);
      return;
    }
    if (_mode == ReactionMode.colour && colour != _inkColour) {
      _misses++;
      _enterFeedback('Wrong colour', consumesTrial: true);
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
    _recordHit();
  }

  void _recordSequenceTap(ReactionDirection? direction) {
    if (direction != _sequence[_entered]) {
      _misses++;
      _enterFeedback('Wrong order', consumesTrial: true);
      return;
    }
    _entered++;
    if (_entered < _sequence.length) {
      return;
    }
    _recordHit();
  }

  void _recordHit() {
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
    _isShowingSequence = false;
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
    _clearStimulus();
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
