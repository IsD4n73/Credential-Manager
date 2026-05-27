import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  static const _uuid = Uuid();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    // Initialize FFI for desktop platforms.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'credential_manager.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _ensureSchema(db);
        await _seedDefaults(db);
      },
      onOpen: (db) async {
        // Safety net for databases left in a broken state from a previous
        // partial init (missing tables would surface as "no such table").
        await _ensureSchema(db);
        await _seedDefaults(db);
      },
    );
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color_index INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS envs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color_value INTEGER NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS credentials (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        env_id TEXT NOT NULL,
        name TEXT NOT NULL,
        username TEXT,
        secret TEXT NOT NULL,
        url TEXT,
        notes TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (env_id) REFERENCES envs(id)
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_credentials_project ON credentials(project_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_credentials_env ON credentials(env_id)');
  }

  Future<void> _seedDefaults(Database db) async {
    final envRows = await db.rawQuery('SELECT COUNT(*) AS c FROM envs');
    final envCount = (envRows.first['c'] as int?) ?? 0;
    if (envCount == 0) {
      for (final entry in EnvPresets.defaults.entries) {
        await db.insert('envs', {
          'id': _uuid.v4(),
          'name': entry.key,
          'color_value': entry.value.toARGB32(),
          'is_custom': 0,
        });
      }
    }
    final projRows = await db.rawQuery('SELECT COUNT(*) AS c FROM projects');
    final projCount = (projRows.first['c'] as int?) ?? 0;
    if (projCount == 0) {
      await db.insert('projects', {
        'id': _uuid.v4(),
        'name': 'Demo Project',
        'description': 'Esempio iniziale — modificami o eliminami',
        'color_index': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ---------- Projects ----------
  Future<List<Project>> listProjects() async {
    final rows = await (await db).query('projects', orderBy: 'name COLLATE NOCASE');
    return rows.map(Project.fromMap).toList();
  }

  Future<Project> createProject({
    required String name,
    String? description,
    required int colorIndex,
  }) async {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      description: description,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
    );
    await (await db).insert('projects', project.toMap());
    return project;
  }

  Future<void> updateProject(Project project) async {
    await (await db).update('projects', project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
  }

  Future<void> deleteProject(String id) async {
    await (await db).delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Envs ----------
  Future<List<EnvDef>> listEnvs() async {
    final rows = await (await db).query('envs', orderBy: 'is_custom ASC, name ASC');
    return rows.map(EnvDef.fromMap).toList();
  }

  Future<EnvDef> createEnv({required String name, required int colorValue}) async {
    final env = EnvDef(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      isCustom: true,
    );
    await (await db).insert('envs', env.toMap());
    return env;
  }

  Future<void> deleteEnv(String id) async {
    await (await db).delete('envs', where: 'id = ? AND is_custom = 1', whereArgs: [id]);
  }

  // ---------- Credentials ----------
  Future<List<Credential>> listCredentials({
    String? projectId,
    String? envId,
    String? search,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (projectId != null) {
      where.add('project_id = ?');
      args.add(projectId);
    }
    if (envId != null) {
      where.add('env_id = ?');
      args.add(envId);
    }
    if (search != null && search.trim().isNotEmpty) {
      where.add('(name LIKE ? OR username LIKE ? OR url LIKE ? OR tags LIKE ?)');
      final q = '%${search.trim()}%';
      args.addAll([q, q, q, q]);
    }
    final rows = await (await db).query(
      'credentials',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'updated_at DESC',
    );
    return rows.map(Credential.fromMap).toList();
  }

  Future<Credential> createCredential({
    required String projectId,
    required String envId,
    required String name,
    String? username,
    required String secret,
    String? url,
    String? notes,
    required List<String> tags,
  }) async {
    final now = DateTime.now();
    final cred = Credential(
      id: _uuid.v4(),
      projectId: projectId,
      envId: envId,
      name: name,
      username: username,
      secret: secret,
      url: url,
      notes: notes,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    await (await db).insert('credentials', cred.toMap());
    return cred;
  }

  Future<void> updateCredential(Credential c) async {
    await (await db).update('credentials', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> deleteCredential(String id) async {
    await (await db).delete('credentials', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Bulk ----------
  Future<void> insertProjectRaw(Project p) async {
    await (await db)
        .insert('projects', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertEnvRaw(EnvDef e) async {
    await (await db)
        .insert('envs', e.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> insertCredentialRaw(Credential c) async {
    await (await db).insert('credentials', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// For exporting: returns plain dump (caller is responsible for encryption).
  Future<Map<String, Object?>> dumpAll() async {
    final database = await db;
    final projects = await database.query('projects');
    final envs = await database.query('envs');
    final credentials = await database.query('credentials');
    return {
      'projects': projects,
      'envs': envs,
      'credentials': credentials,
    };
  }
}
