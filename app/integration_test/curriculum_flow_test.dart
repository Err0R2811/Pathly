import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pathly_app/main.dart' as app;
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_page.dart';
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_preview_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Curriculum Flow Integration Tests', () {
    testWidgets('User can request curriculum generation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to dashboard (assuming user is logged in)
      // In real test, would need to login first
      
      // Tap on "Generate Curriculum" or similar button
      final generateButton = find.text('Generate Curriculum');
      if (generateButton.evaluate().isNotEmpty) {
        await tester.tap(generateButton);
        await tester.pumpAndSettle();
      }

      // Enter skill name
      await tester.enterText(find.byKey(const Key('skill_name_field')), 'Python Programming');
      
      // Submit request
      await tester.tap(find.byKey(const Key('generate_button')));
      await tester.pumpAndSettle();

      // Verify loading state or success message
      expect(
        find.text('Generating your curriculum...').evaluate().isNotEmpty ||
        find.byType(RoadmapPreviewPage).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('User can view roadmap details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a roadmap (assuming one exists)
      final roadmapCard = find.byType(RoadmapPreviewPage);
      if (roadmapCard.evaluate().isNotEmpty) {
        await tester.tap(roadmapCard.first);
        await tester.pumpAndSettle();
      }

      // Verify roadmap page is displayed
      expect(find.byType(RoadmapPage).evaluate().isNotEmpty, true);
      
      // Verify roadmap details are shown
      expect(find.text('Modules').evaluate().isNotEmpty, true);
    });

    testWidgets('User can view module details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to roadmap page
      // (In real test, would navigate through the flow)
      
      // Tap on a module
      final moduleCard = find.byKey(const Key('module_card_0'));
      if (moduleCard.evaluate().isNotEmpty) {
        await tester.tap(moduleCard);
        await tester.pumpAndSettle();
      }

      // Verify module details are shown
      expect(find.text('Learning Objectives').evaluate().isNotEmpty, true);
    });

    testWidgets('User can start a lesson from module', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to module details
      // Then tap on a lesson
      final lessonButton = find.text('Start Lesson');
      if (lessonButton.evaluate().isNotEmpty) {
        await tester.tap(lessonButton);
        await tester.pumpAndSettle();
      }

      // Verify lesson player opens
      expect(find.text('Lesson Content').evaluate().isNotEmpty, true);
    });
  });
}
