import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cryptography/cryptography.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Encrypted vault file format (JSON):
/// magic VAULT1, PBKDF2-HMAC-SHA256 (200k iters, 16-byte salt),
/// AES-GCM-256 (12-byte nonce, 16-byte tag).
class VaultCrypto {
  static const _magic = 'VAULT1';
  static const _version = 1;
  static const _iters = 200000;

  /// Pepper loaded at runtime by flutter_dotenv from the bundled `.env`.
  /// Mixed into the passphrase before PBKDF2 so two installs with different
  /// peppers produce non-interoperable .vault files. Empty by default.
  static String get _pepper => dotenv.maybeGet('APP_PEPPER') ?? '';

  /// Exposed so the UI can show whether this build has a personal pepper.
  static bool get hasPepper => _pepper.isNotEmpty;

  static final _rng = math.Random.secure();

  static Uint8List _randomBytes(int n) {
    final b = Uint8List(n);
    for (var i = 0; i < n; i++) {
      b[i] = _rng.nextInt(256);
    }
    return b;
  }

  static Future<SecretKey> _deriveKey(String passphrase, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iters,
      bits: 256,
    );
    // Append the build-time pepper to the passphrase before stretching.
    // Empty pepper = no-op (OSS default).
    final material = utf8.encode('$passphrase$_pepper');
    return pbkdf2.deriveKey(
      secretKey: SecretKey(material),
      nonce: salt,
    );
  }

  /// Encrypt a JSON-serializable payload into a self-contained string.
  static Future<String> encryptToString(
      String passphrase, Map<String, Object?> payload) async {
    final plain = utf8.encode(jsonEncode(payload));
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = await _deriveKey(passphrase, salt);

    final aes = AesGcm.with256bits();
    final box = await aes.encrypt(
      plain,
      secretKey: key,
      nonce: nonce,
    );

    final envelope = {
      'magic': _magic,
      'version': _version,
      'kdf': {
        'algo': 'pbkdf2-hmac-sha256',
        'iters': _iters,
        'salt': base64Encode(salt),
      },
      'cipher': {
        'algo': 'aes-gcm-256',
        'nonce': base64Encode(nonce),
        'mac': base64Encode(box.mac.bytes),
      },
      'data': base64Encode(box.cipherText),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Returns null when passphrase is wrong or file is corrupted/invalid.
  static Future<Map<String, Object?>?> decryptFromString(
      String passphrase, String text) async {
    Map<String, Object?> envelope;
    try {
      envelope = jsonDecode(text) as Map<String, Object?>;
    } catch (_) {
      return null;
    }
    if (envelope['magic'] != _magic) return null;
    try {
      final kdf = envelope['kdf'] as Map<String, Object?>;
      final cipher = envelope['cipher'] as Map<String, Object?>;
      final salt = base64Decode(kdf['salt'] as String);
      final nonce = base64Decode(cipher['nonce'] as String);
      final mac = base64Decode(cipher['mac'] as String);
      final data = base64Decode(envelope['data'] as String);

      final key = await _deriveKey(passphrase, salt);
      final aes = AesGcm.with256bits();
      final box = SecretBox(data, nonce: nonce, mac: Mac(mac));
      final plain = await aes.decrypt(box, secretKey: key);
      return jsonDecode(utf8.decode(plain)) as Map<String, Object?>;
    } on SecretBoxAuthenticationError {
      return null;
    } catch (_) {
      return null;
    }
  }
}
