import 'package:flutter/foundation.dart';

class LockController extends ChangeNotifier {
  bool _locked = false;
  bool get locked => _locked;

  void lock() {
    if (_locked) return;
    _locked = true;
    notifyListeners();
  }

  void unlock() {
    if (!_locked) return;
    _locked = false;
    notifyListeners();
  }
}
