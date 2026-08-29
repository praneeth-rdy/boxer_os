import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/providers/shell_provider.dart';

void main() {
  test('starts on tab 0', () {
    final shell = ShellProvider();

    expect(shell.tabIndex, 0);
  });

  test('showTab updates tabIndex and notifies listeners', () {
    final shell = ShellProvider();
    var notified = 0;
    shell.addListener(() => notified++);

    shell.showTab(3);

    expect(shell.tabIndex, 3);
    expect(notified, 1);
  });

  test('showTab with the current index does not notify listeners', () {
    final shell = ShellProvider();
    var notified = 0;
    shell.addListener(() => notified++);

    shell.showTab(0);

    expect(shell.tabIndex, 0);
    expect(notified, 0);
  });
}
