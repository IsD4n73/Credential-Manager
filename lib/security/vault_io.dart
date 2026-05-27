import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../db/database.dart';
import '../models/models.dart';
import 'vault_crypto.dart';

class ImportResult {
  final int projects;
  final int envs;
  final int credentials;
  ImportResult(this.projects, this.envs, this.credentials);
}

class VaultIO {
  /// Returns the absolute path of the saved file, or null if user cancelled.
  static Future<String?> exportEncrypted(String passphrase) async {
    final dump = await AppDatabase.instance.dumpAll();
    final encrypted = await VaultCrypto.encryptToString(passphrase, {
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'vault-credential-manager',
      ...dump,
    });

    final suggested =
        'vault-export-${DateTime.now().toIso8601String().substring(0, 10)}.vault';
    final location = await getSaveLocation(
      suggestedName: suggested,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Vault encrypted', extensions: ['vault']),
      ],
    );
    if (location == null) return null;

    final file = File(location.path);
    await file.writeAsString(encrypted);
    return location.path;
  }

  /// Returns null if user cancelled. Throws [VaultIOError] on wrong passphrase
  /// or invalid file.
  static Future<ImportResult?> importEncrypted(String passphrase) async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Vault encrypted', extensions: ['vault']),
        const XTypeGroup(label: 'All', extensions: ['json', 'txt']),
      ],
    );
    if (file == null) return null;

    final text = await File(file.path).readAsString();
    final decoded = await VaultCrypto.decryptFromString(passphrase, text);
    if (decoded == null) {
      throw const VaultIOError('Passphrase errata o file non valido.');
    }

    final projectsRaw = (decoded['projects'] as List?)?.cast<Map>() ?? const [];
    final envsRaw = (decoded['envs'] as List?)?.cast<Map>() ?? const [];
    final credsRaw =
        (decoded['credentials'] as List?)?.cast<Map>() ?? const [];

    final db = AppDatabase.instance;

    // Envs first (so credentials don't fail FK).
    for (final r in envsRaw) {
      await db.insertEnvRaw(EnvDef.fromMap(_normalize(r)));
    }
    // Projects.
    for (final r in projectsRaw) {
      await db.insertProjectRaw(Project.fromMap(_normalize(r)));
    }
    // Credentials.
    for (final r in credsRaw) {
      try {
        await db.insertCredentialRaw(Credential.fromMap(_normalize(r)));
      } catch (_) {
        // skip invalid rows
      }
    }
    return ImportResult(projectsRaw.length, envsRaw.length, credsRaw.length);
  }

  static Map<String, Object?> _normalize(Map map) {
    return map.map((k, v) => MapEntry(k.toString(), v));
  }
}

class VaultIOError implements Exception {
  final String message;
  const VaultIOError(this.message);
  @override
  String toString() => message;
}
