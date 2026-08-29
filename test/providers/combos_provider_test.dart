import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boxer_os/data/combination_library.dart';
import 'package:boxer_os/models/combination.dart';
import 'package:boxer_os/models/difficulty.dart';
import 'package:boxer_os/providers/combos_provider.dart';

Combination _generated() => const Combination(
  moves: ['1', '2'],
  difficulty: Difficulty.beginner,
  seed: 1,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CombosProvider.toggleSaved', () {
    test(
      'saving a library combination persists it under saved_combinations',
      () async {
        final provider = CombosProvider();
        await provider.load();
        final combination = combinationLibrary.first;

        await provider.toggleSaved(combination);

        expect(provider.isSaved(combination), isTrue);
        expect(provider.saved, [combination]);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(CombosProvider.savedKey), isNotNull);
      },
    );

    test('toggling a saved combination again removes it', () async {
      final provider = CombosProvider();
      await provider.load();
      final combination = combinationLibrary.first;
      await provider.toggleSaved(combination);

      await provider.toggleSaved(combination);

      expect(provider.isSaved(combination), isFalse);
      expect(provider.saved, isEmpty);
    });

    test('a reloaded provider sees the same bookmarks', () async {
      final first = CombosProvider();
      await first.load();
      await first.toggleSaved(combinationLibrary[0]);
      await first.toggleSaved(combinationLibrary[1]);

      final second = CombosProvider();
      await second.load();

      expect(second.saved, [combinationLibrary[0], combinationLibrary[1]]);
    });
  });

  group('CombosProvider.isSaved', () {
    test('matches a library entry by id even if its fields changed', () async {
      final provider = CombosProvider();
      await provider.load();
      final combination = combinationLibrary.first;
      await provider.toggleSaved(combination);

      final renamed = Combination(
        id: combination.id,
        moves: const ['x'],
        difficulty: Difficulty.advanced,
        seed: 99,
        name: 'Renamed',
      );

      expect(provider.isSaved(renamed), isTrue);
    });

    test(
      'matches a generated combination by its moves and difficulty',
      () async {
        final provider = CombosProvider();
        await provider.load();
        final combination = _generated();
        await provider.toggleSaved(combination);

        expect(
          provider.isSaved(
            const Combination(
              moves: ['1', '2'],
              difficulty: Difficulty.beginner,
              seed: 42,
            ),
          ),
          isTrue,
        );
      },
    );

    test('a combination with different moves is not saved', () async {
      final provider = CombosProvider();
      await provider.load();

      expect(provider.isSaved(_generated()), isFalse);
    });
  });

  group('CombosProvider.remove', () {
    test('removes a saved combination and persists the change', () async {
      final provider = CombosProvider();
      await provider.load();
      final combination = combinationLibrary.first;
      await provider.toggleSaved(combination);

      await provider.remove(combination);

      expect(provider.saved, isEmpty);

      final reloaded = CombosProvider();
      await reloaded.load();
      expect(reloaded.saved, isEmpty);
    });
  });
}
