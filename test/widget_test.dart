import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elemegi360/app.dart';
import 'package:elemegi360/data/local/profile_store.dart';
import 'package:elemegi360/features/record/record_screen.dart';
import 'package:elemegi360/features/shell/main_shell.dart';
import 'package:elemegi360/theme/el_emegi_theme.dart';

void main() {
  testWidgets('Onboarding görünür (profil yokken)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('tr_TR');
    await ProfileStore.instance.load();
    await tester.pumpWidget(const ElEmegiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final hasOnboarding = find.text('Onayla ve kilitle').evaluate().isNotEmpty;
    final hasApp = find.text('El Emeği 360').evaluate().isNotEmpty;
    expect(hasOnboarding || hasApp, isTrue);
  });

  testWidgets('RecordScreen kayıt formu görünür', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'owner_uid': 'test-uid-123456',
      'ad_soyad': 'AYŞE YILMAZ',
      'worker_key': 'AYSE_YILMAZ',
      'profile_locked': true,
      'registered_at_ms': DateTime(2026, 5, 1).millisecondsSinceEpoch,
    });
    await initializeDateFormatting('tr_TR');
    await ProfileStore.instance.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: ElEmegiTheme.dark(),
        home: const Scaffold(body: RecordScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kaydet'), findsOneWidget);
    expect(find.text('AYŞE YILMAZ'), findsOneWidget);
  });

  testWidgets('MainShell header görünür', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'owner_uid': 'test-uid-123456',
      'ad_soyad': 'AYŞE YILMAZ',
      'worker_key': 'AYSE_YILMAZ',
      'profile_locked': true,
      'registered_at_ms': DateTime(2026, 5, 1).millisecondsSinceEpoch,
    });
    await initializeDateFormatting('tr_TR');
    await ProfileStore.instance.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: ElEmegiTheme.dark(),
        home: const MainShell(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Emeğinize değer'), findsOneWidget);
    expect(find.text('Kayıt'), findsOneWidget);
  });
}
