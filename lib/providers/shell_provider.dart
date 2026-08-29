import 'package:flutter/foundation.dart';

/// Which of the four shell tabs is showing.
class ShellProvider extends ChangeNotifier {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  void showTab(int index) {
    if (_tabIndex == index) {
      return;
    }
    _tabIndex = index;
    notifyListeners();
  }
}
