import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/utils/external_links.dart';

void main() {
  final originalLauncher = launcher;

  tearDown(() {
    launcher = originalLauncher;
  });

  test('openExternal returns what the launcher reports', () async {
    launcher = (url) async => true;

    expect(await openExternal('https://example.com'), isTrue);
  });

  test('openExternal passes the url through to the launcher', () async {
    final requested = <String>[];
    launcher = (url) async {
      requested.add(url);
      return true;
    };

    await openExternal('https://example.com/page');

    expect(requested, ['https://example.com/page']);
  });

  test(
    'openExternal returns false when the launcher reports failure',
    () async {
      launcher = (url) async => false;

      expect(await openExternal('https://example.com'), isFalse);
    },
  );

  test('openExternal returns false when the launcher throws', () async {
    launcher = (url) async => throw Exception('platform unavailable');

    expect(await openExternal('https://example.com'), isFalse);
  });
}
