import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_data.dart';
import '../models/experience_item.dart';
import 'snapshot_service.dart';

class SupabaseDbService {
  final SupabaseClient? _customClient;
  SupabaseDbService([this._customClient]);

  SupabaseClient get _client {
    if (_customClient != null) return _customClient;
    return Supabase.instance.client;
  }

  // Health check for backend
  Future<bool> checkBackendHealth() async {
    try {
      final res = await _client
          .from('content')
          .select('section')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      return res.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Projects Collection Stream with 6-second snapshot fallback
  Stream<List<ProjectData>> getProjectsStream({void Function(bool isOffline)? onStatusChange}) {
    final controller = StreamController<List<ProjectData>>.broadcast();
    var hasEmittedFirstLive = false;
    StreamSubscription? sub;

    Timer? fallbackTimer = Timer(const Duration(seconds: 6), () async {
      if (!hasEmittedFirstLive) {
        onStatusChange?.call(true);
        final fallback = await SnapshotService.getProjects();
        if (!controller.isClosed) {
          controller.add(fallback);
        }
      }
    });

    final liveStream = _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
      return data.map((json) => ProjectData.fromJson(json)).toList();
    });

    sub = liveStream.listen(
      (projects) {
        fallbackTimer?.cancel();
        fallbackTimer = null;
        hasEmittedFirstLive = true;
        onStatusChange?.call(false);
        if (!controller.isClosed) {
          controller.add(projects);
        }
      },
      onError: (err) async {
        if (!hasEmittedFirstLive) {
          fallbackTimer?.cancel();
          fallbackTimer = null;
          onStatusChange?.call(true);
          final fallback = await SnapshotService.getProjects();
          if (!controller.isClosed) {
            controller.add(fallback);
          }
        }
      },
    );

    controller.onCancel = () {
      fallbackTimer?.cancel();
      sub?.cancel();
    };

    return controller.stream;
  }

  // General Text Content Stream (for Home, About, etc.) with 6-second snapshot fallback
  Stream<Map<String, dynamic>> getContentStream(String section, {void Function(bool isOffline)? onStatusChange}) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    var hasEmittedFirstLive = false;
    StreamSubscription? sub;

    Timer? fallbackTimer = Timer(const Duration(seconds: 6), () async {
      if (!hasEmittedFirstLive) {
        onStatusChange?.call(true);
        final fallback = await SnapshotService.getContent(section);
        if (!controller.isClosed) {
          controller.add(fallback);
        }
      }
    });

    final liveStream = _client
        .from('content')
        .stream(primaryKey: ['section'])
        .eq('section', section)
        .map((data) {
      if (data.isEmpty) return <String, dynamic>{};
      return data.first['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    });

    sub = liveStream.listen(
      (content) {
        fallbackTimer?.cancel();
        fallbackTimer = null;
        hasEmittedFirstLive = true;
        onStatusChange?.call(false);
        if (!controller.isClosed) {
          controller.add(content);
        }
      },
      onError: (err) async {
        if (!hasEmittedFirstLive) {
          fallbackTimer?.cancel();
          fallbackTimer = null;
          onStatusChange?.call(true);
          final fallback = await SnapshotService.getContent(section);
          if (!controller.isClosed) {
            controller.add(fallback);
          }
        }
      },
    );

    controller.onCancel = () {
      fallbackTimer?.cancel();
      sub?.cancel();
    };

    return controller.stream;
  }

  // Update Project
  Future<void> updateProject(ProjectData project) async {
    await _client
        .from('projects')
        .update(project.toJson())
        .eq('id', project.id);
  }

  // Add Project
  Future<void> addProject(ProjectData project) async {
    final data = project.toJson();
    if (project.id.isNotEmpty && project.id.length > 5) { // Assuming UUID length
       await _client.from('projects').upsert({...data, 'id': project.id});
    } else {
       await _client.from('projects').insert(data);
    }
  }

  // Delete Project
  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }

  // Update General Content (safely merging with existing data)
  Future<void> updateContent(String section, Map<String, dynamic> data) async {
    if (_client.auth.currentSession == null) {
      throw const AuthException('Unauthorized: Active admin session required to update content.');
    }
    try {
      final existing = await _client
          .from('content')
          .select('data')
          .eq('section', section)
          .maybeSingle();

      final existingMap = (existing != null && existing['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(existing['data'])
          : <String, dynamic>{};

      final merged = {...existingMap, ...data};

      await _client.from('content').upsert({
        'section': section,
        'data': merged,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fallback direct upsert
      await _client.from('content').upsert({
        'section': section,
        'data': data,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Persist custom projects order both in content and projects tables
  Future<void> saveProjectsOrder(List<String> projectIds) async {
    await updateContent('projects_order', {
      'order': projectIds,
    });
    if (_client.auth.currentSession != null) {
      for (int i = 0; i < projectIds.length; i++) {
        try {
          await _client
              .from('projects')
              .update({'order_index': i})
              .eq('id', projectIds[i]);
        } catch (_) {}
      }
    }
  }

  // Persist Experience / Education Items list
  Future<void> saveExperienceItems(List<ExperienceItem> items) async {
    await updateContent('experience', {
      'items': items.map((e) => e.toJson()).toList(),
    });
  }
}
