import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/project_data.dart';

class SnapshotService {
  static Map<String, dynamic>? _cachedSnapshot;

  static Future<Map<String, dynamic>> _loadSnapshot() async {
    if (_cachedSnapshot != null) return _cachedSnapshot!;
    try {
      final jsonString = await rootBundle.loadString('assets/content_snapshot.json');
      _cachedSnapshot = jsonDecode(jsonString) as Map<String, dynamic>;
      return _cachedSnapshot!;
    } catch (e) {
      return {};
    }
  }

  static Future<List<ProjectData>> getProjects() async {
    final snapshot = await _loadSnapshot();
    final rawProjects = snapshot['projects'] as List<dynamic>? ?? [];
    return rawProjects.map((p) => ProjectData.fromJson(Map<String, dynamic>.from(p))).toList();
  }

  static Future<Map<String, dynamic>> getContent(String section) async {
    final snapshot = await _loadSnapshot();
    final rawContent = snapshot['content'] as List<dynamic>? ?? [];
    for (final row in rawContent) {
      if (row is Map && row['section'] == section) {
        final data = row['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    }
    return {};
  }
}
