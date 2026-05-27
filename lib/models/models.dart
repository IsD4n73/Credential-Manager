import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final int colorIndex;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.colorIndex,
    required this.createdAt,
  });

  Color get color =>
      AppColors.projectPalette[colorIndex % AppColors.projectPalette.length];

  Project copyWith({
    String? name,
    String? description,
    int? colorIndex,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color_index': colorIndex,
        'created_at': createdAt.toIso8601String(),
      };

  static Project fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        colorIndex: (map['color_index'] as int?) ?? 0,
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class EnvDef {
  final String id;
  final String name;
  final int colorValue;
  final bool isCustom;

  EnvDef({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.isCustom,
  });

  Color get color => Color(colorValue);

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'color_value': colorValue,
        'is_custom': isCustom ? 1 : 0,
      };

  static EnvDef fromMap(Map<String, Object?> map) => EnvDef(
        id: map['id'] as String,
        name: map['name'] as String,
        colorValue: map['color_value'] as int,
        isCustom: (map['is_custom'] as int? ?? 0) == 1,
      );
}

class Credential {
  final String id;
  final String projectId;
  final String envId;
  final String name;
  final String? username;
  final String secret;
  final String? url;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Credential({
    required this.id,
    required this.projectId,
    required this.envId,
    required this.name,
    this.username,
    required this.secret,
    this.url,
    this.notes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Credential copyWith({
    String? projectId,
    String? envId,
    String? name,
    String? username,
    String? secret,
    String? url,
    String? notes,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Credential(
      id: id,
      projectId: projectId ?? this.projectId,
      envId: envId ?? this.envId,
      name: name ?? this.name,
      username: username ?? this.username,
      secret: secret ?? this.secret,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'project_id': projectId,
        'env_id': envId,
        'name': name,
        'username': username,
        'secret': secret,
        'url': url,
        'notes': notes,
        'tags': jsonEncode(tags),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Credential fromMap(Map<String, Object?> map) {
    final tagsRaw = map['tags'] as String? ?? '[]';
    final tagsList = (jsonDecode(tagsRaw) as List).cast<String>();
    return Credential(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      envId: map['env_id'] as String,
      name: map['name'] as String,
      username: map['username'] as String?,
      secret: map['secret'] as String? ?? '',
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      tags: tagsList,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
