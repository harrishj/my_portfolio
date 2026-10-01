import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/providers/app_providers.dart';
import 'package:portfolio/services/storage_service.dart';
import 'package:portfolio/services/supabase_db_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('PortfolioApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PortfolioApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PortfolioHome), findsOneWidget);
  });

  testWidgets('Visitor / Not Logged In: Edit icon is completely hidden', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAdminProvider.overrideWithValue(false),
        ],
        child: const PortfolioApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Edit icon and tooltip must NOT be present
    expect(find.byTooltip('Change Profile Image'), findsNothing);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
  });

  testWidgets('Admin Logged In: Edit icon is visible and interactive', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAdminProvider.overrideWithValue(true),
        ],
        child: const PortfolioApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Edit icon and tooltip MUST be present
    expect(find.byTooltip('Change Profile Image'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
  });

  test('Security Check: StorageService rejects upload when unauthenticated', () async {
    final client = SupabaseClient('https://mock.supabase.co', 'mock-anon-key');
    final storage = StorageService(client);
    expect(
      () => storage.uploadGeneralImage('test.png', Uint8List.fromList([1, 2, 3])),
      throwsA(isA<AuthException>()),
    );
  });

  test('Security Check: SupabaseDbService rejects content update when unauthenticated', () async {
    final client = SupabaseClient('https://mock.supabase.co', 'mock-anon-key');
    final db = SupabaseDbService(client);
    expect(
      () => db.updateContent('hero', {'profileImage': 'https://test.com/img.png'}),
      throwsA(isA<AuthException>()),
    );
  });
}
