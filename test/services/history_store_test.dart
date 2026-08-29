import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/reaction_result.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/services/history_store.dart';

SessionRecord _session(String id) => SessionRecord(
  id: id,
  workoutId: 'w',
  workoutName: 'Workout',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: DateTime.utc(2026, 8, 29, 10),
  durationSeconds: 180,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
);

final ReactionResult _reaction = ReactionResult(
  mode: ReactionMode.tap,
  completedAt: DateTime.utc(2026, 8, 29, 10),
  reactionMillis: [220, 240],
  falseStarts: 1,
  misses: 0,
);

void main() {
  group('HistoryStore sessions', () {
    test('round-trips sessions through mocked prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      final saved = await store.saveSessions([_session('1'), _session('2')]);
      final loaded = await store.loadSessions();

      expect(saved, isTrue);
      expect(loaded.map((record) => record.id), ['1', '2']);
    });

    test('loadSessions returns an empty list for corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        HistoryStore.sessionsKey: 'not valid json',
      });
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      expect(await store.loadSessions(), isEmpty);
    });

    test('skips a corrupt entry inside an otherwise valid list', () async {
      final valid = _session('1').toJson();
      final corrupt = {..._session('2').toJson(), 'duration_seconds': 'oops'};
      SharedPreferences.setMockInitialValues({
        HistoryStore.sessionsKey: jsonEncode([valid, corrupt]),
      });
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      final loaded = await store.loadSessions();

      expect(loaded.map((record) => record.id), ['1']);
    });
  });

  group('HistoryStore reactions', () {
    test('round-trips reactions through mocked prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      final saved = await store.saveReactions([_reaction]);
      final loaded = await store.loadReactions();

      expect(saved, isTrue);
      expect(loaded, [_reaction]);
    });

    test('loadReactions returns an empty list for corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        HistoryStore.reactionsKey: '{not a list',
      });
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      expect(await store.loadReactions(), isEmpty);
    });

    test('skips a corrupt entry inside an otherwise valid list', () async {
      final valid = _reaction.toJson();
      final corrupt = {..._reaction.toJson(), 'reaction_millis': 'oops'};
      SharedPreferences.setMockInitialValues({
        HistoryStore.reactionsKey: jsonEncode([valid, corrupt]),
      });
      final store = HistoryStore(prefs: await SharedPreferences.getInstance());

      final loaded = await store.loadReactions();

      expect(loaded, [_reaction]);
    });
  });
}
