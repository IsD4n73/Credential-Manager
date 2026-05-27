import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric / device authentication wrapper.
///
/// The DB is local to the device, so the biometric prompt is an *access gate*
/// rather than encryption-at-rest. For at-rest protection users should use the
/// encrypted import/export.
class BiometricService extends ChangeNotifier {
  static const _prefKey = 'lock_enabled';

  final LocalAuthentication _auth = LocalAuthentication();
  SharedPreferences? _prefs;

  bool _supported = false;
  bool _lockEnabled = false;
  List<BiometricType> _types = const [];

  bool get supported => _supported;
  // Master password is always available as a fallback, so lock can be
  // enabled even when biometric isn't supported.
  bool get lockEnabled => _lockEnabled;
  List<BiometricType> get availableTypes => _types;

  /// Returns a stable key — the UI layer maps it to a localized string.
  /// Values: 'face' | 'fingerprint' | 'iris' | 'biometrics' | 'devicePin'.
  String get friendlyTypeKey {
    if (_types.contains(BiometricType.face)) return 'face';
    if (_types.contains(BiometricType.fingerprint)) return 'fingerprint';
    if (_types.contains(BiometricType.iris)) return 'iris';
    if (_types.contains(BiometricType.strong) ||
        _types.contains(BiometricType.weak)) {
      return 'biometrics';
    }
    return 'devicePin';
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _lockEnabled = _prefs?.getBool(_prefKey) ?? false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      _supported = canCheck || isSupported;
      if (_supported) {
        _types = await _auth.getAvailableBiometrics();
      }
    } catch (_) {
      _supported = false;
    }
    notifyListeners();
  }

  Future<void> setLockEnabled(bool value) async {
    _lockEnabled = value;
    await _prefs?.setBool(_prefKey, value);
    notifyListeners();
  }

  Future<bool> authenticate({String reason = 'Unlock'}) async {
    if (!_supported) return true;
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }
}
