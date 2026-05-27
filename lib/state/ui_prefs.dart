import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiPrefs extends ChangeNotifier {
  static const _kSidebarCollapsed = 'ui.sidebar_collapsed';

  SharedPreferences? _prefs;
  bool _sidebarCollapsed = false;

  bool get sidebarCollapsed => _sidebarCollapsed;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _sidebarCollapsed = _prefs?.getBool(_kSidebarCollapsed) ?? false;
    notifyListeners();
  }

  Future<void> setSidebarCollapsed(bool v) async {
    _sidebarCollapsed = v;
    await _prefs?.setBool(_kSidebarCollapsed, v);
    notifyListeners();
  }

  void toggleSidebar() => setSidebarCollapsed(!_sidebarCollapsed);
}
