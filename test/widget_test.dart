// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:login_1/main.dart';

void main() {
  testWidgets('SoundVault smoke test muestra pantalla de login', (WidgetTester tester) async {
    // Inicializa Supabase para que los providers funcionen en test
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test_anon_key',
    );

    // Carga la app con Riverpod
    await tester.pumpWidget(const ProviderScope(child: SoundVaultApp()));
    await tester.pumpAndSettle();

    // Verifica que se muestre la pantalla de login
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
