import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/models/session_record.dart';
import 'package:boxer_os/models/stance.dart';
import 'package:boxer_os/models/training_type.dart';

SessionRecord _record({int? rating, String? whatWorked}) => SessionRecord(
  id: '1735689600000',
  workoutId: 'shadow_foundations',
  workoutName: 'Shadow Foundations',
  type: TrainingType.shadowBoxing,
  difficulty: Difficulty.beginner,
  stance: Stance.orthodox,
  startedAt: DateTime.utc(2026, 8, 29, 10, 30),
  durationSeconds: 725,
  roundsCompleted: 3,
  roundsPlanned: 3,
  completed: true,
  rating: rating,
  whatWorked: whatWorked,
);

void main() {
  group('SessionRecord JSON round trip', () {
    test('round-trips with rating and journal notes set', () {
      final record = _record(rating: 4, whatWorked: 'Felt sharp today');

      final restored = SessionRecord.fromJson(record.toJson());

      expect(restored.toJson(), record.toJson());
      expect(restored.rating, 4);
      expect(restored.whatWorked, 'Felt sharp today');
      expect(restored.startedAt, record.startedAt);
    });

    test('round-trips with null rating and notes omitted from the map', () {
      final record = _record();

      final json = record.toJson();

      expect(json.containsKey('rating'), false);
      expect(json.containsKey('what_worked'), false);

      final restored = SessionRecord.fromJson(json);

      expect(restored.rating, null);
      expect(restored.whatWorked, null);
      expect(restored.toJson(), json);
    });

    test('fromJson defaults missing fields and falls back unknown enums', () {
      final record = SessionRecord.fromJson(const {});

      expect(record.type, TrainingType.custom);
      expect(record.difficulty, Difficulty.beginner);
      expect(record.stance, Stance.orthodox);
      expect(record.completed, false);
      expect(record.rating, null);
      expect(record.whatWorked, null);
      expect(record.opponentStance, null);
    });
  });

  group('SessionRecord getters', () {
    test('workMinutes rounds duration to the nearest minute', () {
      expect(_record(rating: null).durationSeconds, 725);
      expect(_record().workMinutes, 12);
    });
  });

  group('SessionRecord.copyWith', () {
    test('replaces only the rating and journal fields', () {
      final original = _record();

      final updated = original.copyWith(rating: 5, whatWorked: 'Great session');

      expect(updated.rating, 5);
      expect(updated.whatWorked, 'Great session');
      expect(updated.id, original.id);
      expect(updated.workoutId, original.workoutId);
      expect(updated.startedAt, original.startedAt);
    });
  });
}
