import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/reaction_mode.dart';
import 'package:boxer_os/models/reaction_result.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';
import 'package:boxer_os/providers/history_provider.dart';
import 'package:boxer_os/services/history_store.dart';

SessionRecord _session(String id, {DateTime? startedAt}) => SessionRecord(
  id: id,
  workoutId: 'w',
  workoutName: 'Workout',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: startedAt ?? DateTime.utc(2026, 8, 29, 10),
  durationSeconds: 180,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
);

ReactionResult _reaction(DateTime completedAt) => ReactionResult(
  mode: ReactionMode.tap,
  completedAt: completedAt,
  reactionMillis: const [220],
  falseStarts: 0,
  misses: 0,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryProvider.addSession', () {
    test('adding the same id twice keeps one entry', () async {
      final provider = HistoryProvider();

      await provider.addSession(_session('1'));
      await provider.addSession(_session('1'));

      expect(provider.sessions.length, 1);
    });

    test('sessions are ordered newest first', () async {
      final provider = HistoryProvider();

      await provider.addSession(
        _session('older', startedAt: DateTime.utc(2026, 8, 27)),
      );
      await provider.addSession(
        _session('newer', startedAt: DateTime.utc(2026, 8, 29)),
      );

      expect(provider.sessions.map((record) => record.id), ['newer', 'older']);
    });

    test(
      'persists so a fresh provider over the same prefs loads it back',
      () async {
        final first = HistoryProvider();
        await first.addSession(_session('1'));

        final second = HistoryProvider();
        await second.load();

        expect(second.sessions.map((record) => record.id), ['1']);
      },
    );
  });

  group('HistoryProvider mutations', () {
    test('deleteSession removes the entry and persists', () async {
      final provider = HistoryProvider();
      await provider.addSession(_session('1'));

      await provider.deleteSession('1');

      expect(provider.sessions, isEmpty);
      final reloaded = HistoryProvider();
      await reloaded.load();
      expect(reloaded.sessions, isEmpty);
    });

    test('findSession returns the matching record or null', () async {
      final provider = HistoryProvider();
      await provider.addSession(_session('1'));

      expect(provider.findSession('1')?.id, '1');
      expect(provider.findSession('missing'), isNull);
    });

    test('addReaction stores reactions newest first', () async {
      final provider = HistoryProvider();

      await provider.addReaction(_reaction(DateTime.utc(2026, 8, 27)));
      await provider.addReaction(_reaction(DateTime.utc(2026, 8, 29)));

      expect(provider.reactions.first.completedAt, DateTime.utc(2026, 8, 29));
    });

    test('clearAll empties both lists and persists', () async {
      final provider = HistoryProvider();
      await provider.addSession(_session('1'));
      await provider.addReaction(_reaction(DateTime.utc(2026, 8, 29)));

      await provider.clearAll();

      expect(provider.sessions, isEmpty);
      expect(provider.reactions, isEmpty);
      expect(provider.error, isNull);
    });
  });

  group('HistoryProvider error surfacing', () {
    test('a failing save sets error without throwing', () async {
      final failingStore = _FailingHistoryStore();
      final provider = HistoryProvider(store: failingStore);

      await provider.addSession(_session('1'));

      expect(provider.error, 'Could not save history');
      // The in-memory list is still the truth for the session even though the save failed.
      expect(provider.sessions.length, 1);
    });
  });
}

class _FailingHistoryStore extends HistoryStore {
  @override
  Future<bool> saveSessions(List<SessionRecord> sessions) async => false;

  @override
  Future<bool> saveReactions(List<ReactionResult> reactions) async => false;
}
