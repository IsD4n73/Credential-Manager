import 'package:flutter/foundation.dart';

import '../db/database.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  List<Project> projects = [];
  List<EnvDef> envs = [];
  List<Credential> credentials = [];

  String? selectedProjectId; // null = all
  String? selectedEnvId; // null = all
  String searchQuery = '';
  bool loading = true;

  Future<void> init() async {
    await reloadAll();
    loading = false;
    notifyListeners();
  }

  Future<void> reloadAll() async {
    projects = await _db.listProjects();
    envs = await _db.listEnvs();
    await reloadCredentials();
  }

  Future<void> reloadCredentials() async {
    credentials = await _db.listCredentials(
      projectId: selectedProjectId,
      envId: selectedEnvId,
      search: searchQuery,
    );
    notifyListeners();
  }

  EnvDef? envById(String id) {
    for (final e in envs) {
      if (e.id == id) return e;
    }
    return null;
  }

  Project? projectById(String id) {
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ----- Filters -----
  Future<void> selectProject(String? id) async {
    selectedProjectId = id;
    await reloadCredentials();
  }

  Future<void> selectEnv(String? id) async {
    selectedEnvId = id;
    await reloadCredentials();
  }

  Future<void> setSearch(String q) async {
    searchQuery = q;
    await reloadCredentials();
  }

  // ----- Projects -----
  Future<Project> createProject({
    required String name,
    String? description,
    required int colorIndex,
  }) async {
    final p = await _db.createProject(
      name: name,
      description: description,
      colorIndex: colorIndex,
    );
    projects = await _db.listProjects();
    notifyListeners();
    return p;
  }

  Future<void> updateProject(Project p) async {
    await _db.updateProject(p);
    projects = await _db.listProjects();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteProject(id);
    if (selectedProjectId == id) selectedProjectId = null;
    await reloadAll();
  }

  // ----- Envs -----
  Future<EnvDef> createEnv({required String name, required int colorValue}) async {
    final e = await _db.createEnv(name: name, colorValue: colorValue);
    envs = await _db.listEnvs();
    notifyListeners();
    return e;
  }

  Future<void> deleteEnv(String id) async {
    await _db.deleteEnv(id);
    if (selectedEnvId == id) selectedEnvId = null;
    envs = await _db.listEnvs();
    await reloadCredentials();
  }

  // ----- Credentials -----
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
    final c = await _db.createCredential(
      projectId: projectId,
      envId: envId,
      name: name,
      username: username,
      secret: secret,
      url: url,
      notes: notes,
      tags: tags,
    );
    await reloadCredentials();
    return c;
  }

  Future<void> updateCredential(Credential c) async {
    await _db.updateCredential(c);
    await reloadCredentials();
  }

  Future<void> deleteCredential(String id) async {
    await _db.deleteCredential(id);
    await reloadCredentials();
  }

  /// All distinct tags across credentials (handy for filter chips).
  List<String> get allTags {
    final set = <String>{};
    for (final c in credentials) {
      set.addAll(c.tags);
    }
    final l = set.toList()..sort();
    return l;
  }
}
