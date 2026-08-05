import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pathly_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigate to onboarding on first launch', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show onboarding page on first launch
      expect(find.text('Welcome to Pathly'), findsOneWidget);
    });
  });
}
