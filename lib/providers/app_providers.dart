import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_db_service.dart';
import '../services/storage_service.dart';
import '../services/email_contact_service.dart';
import '../models/project_data.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final dbServiceProvider = Provider<SupabaseDbService>((ref) => SupabaseDbService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final emailContactServiceProvider = Provider<EmailContactService>((ref) => EmailContactService());

// Backend Connectivity State
class BackendOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOffline(bool offline) {
    if (state != offline) {
      state = offline;
    }
  }
}

final backendOfflineProvider = NotifierProvider<BackendOfflineNotifier, bool>(BackendOfflineNotifier.new);

// Auth & Admin State
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final isAdminProvider = Provider<bool>((ref) {
  final session = ref.watch(authStateProvider).value?.session;
  if (session != null) return true;
  try {
    return Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    return false;
  }
});

// Data Streams with graceful snapshot fallback
final projectsProvider = StreamProvider<List<ProjectData>>((ref) {
  final db = ref.watch(dbServiceProvider);
  return db.getProjectsStream(
    onStatusChange: (isOffline) {
      ref.read(backendOfflineProvider.notifier).setOffline(isOffline);
    },
  );
});

final contentProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, section) {
  final db = ref.watch(dbServiceProvider);
  return db.getContentStream(
    section,
    onStatusChange: (isOffline) {
      ref.read(backendOfflineProvider.notifier).setOffline(isOffline);
    },
  );
});

// Reordered Projects Provider respecting saved custom order
final orderedProjectsProvider = Provider<AsyncValue<List<ProjectData>>>((ref) {
  final projectsAsync = ref.watch(projectsProvider);
  final orderAsync = ref.watch(contentProvider('projects_order'));

  return projectsAsync.whenData((projects) {
    final orderData = orderAsync.value ?? {};
    final List<dynamic> savedOrder = orderData['order'] as List<dynamic>? ?? [];

    if (savedOrder.isEmpty) {
      final sorted = List<ProjectData>.from(projects);
      sorted.sort((a, b) => (a.orderIndex ?? 9999).compareTo(b.orderIndex ?? 9999));
      return sorted;
    }

    final idMap = {for (var p in projects) p.id: p};
    final ordered = <ProjectData>[];

    for (final id in savedOrder) {
      if (idMap.containsKey(id.toString())) {
        ordered.add(idMap.remove(id.toString())!);
      }
    }
    // Append any newly added projects not yet listed in saved order
    ordered.addAll(idMap.values);
    return ordered;
  });
});

// App Initialization State for Seamless Splash / Loading Transition
final isAppInitializedProvider = Provider<bool>((ref) {
  final projects = ref.watch(projectsProvider);
  final hero = ref.watch(contentProvider('hero'));
  final about = ref.watch(contentProvider('about'));

  final hasProjects = projects.hasValue || projects.hasError;
  final hasHero = hero.hasValue || hero.hasError;
  final hasAbout = about.hasValue || about.hasError;

  return hasProjects && hasHero && hasAbout;
});

