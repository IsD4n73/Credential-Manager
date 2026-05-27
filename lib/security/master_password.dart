import 'dart:convert';
import 'dart:math' as math;

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores a salted PBKDF2 hash of the user's master password and verifies
/// attempts against it. The password itself is never stored.
class MasterPasswordService extends ChangeNotifier {
  static const _kSalt = 'mp.salt';
  static const _kHash = 'mp.hash';
  static const _iters = 200000;
  static const _bits = 256;

  SharedPreferences? _prefs;
  bool _isSet = false;

  bool get isSet => _isSet;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isSet = _prefs?.getString(_kHash) != null;
    notifyListeners();
  }

  Future<void> set(String password) async {
    final salt = _randomBytes(16);
    final hash = await _derive(password, salt);
    await _prefs?.setString(_kSalt, base64Encode(salt));
    await _prefs?.setString(_kHash, base64Encode(hash));
    _isSet = true;
    notifyListeners();
  }

  Future<bool> verify(String password) async {
    final saltB64 = _prefs?.getString(_kSalt);
    final hashB64 = _prefs?.getString(_kHash);
    if (saltB64 == null || hashB64 == null) return false;
    final salt = base64Decode(saltB64);
    final stored = base64Decode(hashB64);
    final derived = await _derive(password, salt);
    return _constantTimeEq(derived, stored);
  }

  Future<void> clear() async {
    await _prefs?.remove(_kSalt);
    await _prefs?.remove(_kHash);
    _isSet = false;
    notifyListeners();
  }

  // ---------- crypto helpers ----------
  static final _rng = math.Random.secure();

  static Uint8List _randomBytes(int n) {
    final b = Uint8List(n);
    for (var i = 0; i < n; i++) {
      b[i] = _rng.nextInt(256);
    }
    return b;
  }

  static Future<Uint8List> _derive(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iters,
      bits: _bits,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  static bool _constantTimeEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
