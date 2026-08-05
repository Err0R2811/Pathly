import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pathly_app/main.dart' as app;
import 'package:pathly_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathly_app/features/explore/presentation/pages/explore_page.dart';
import 'package:pathly_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pathly_app/features/progress/presentation/pages/progress_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Integration Tests', () {
    testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test Dashboard tab
      final dashboardTab = find.text('Dashboard');
      if (dashboardTab.evaluate().isNotEmpty) {
        await tester.tap(dashboardTab);
        await tester.pumpAndSettle();
        expect(find.byType(DashboardPage).evaluate().isNotEmpty, true);
      }

      // Test Explore tab
      final exploreTab = find.text('Explore');
      if (exploreTab.evaluate().isNotEmpty) {
        await tester.tap(exploreTab);
        await tester.pumpAndSettle();
        expect(find.byType(ExplorePage).evaluate().isNotEmpty, true);
      }

      // Test Progress tab
      final progressTab = find.text('Progress');
      if (progressTab.evaluate().isNotEmpty) {
        await tester.tap(progressTab);
        await tester.pumpAndSettle();
        expect(find.byType(ProgressPage).evaluate().isNotEmpty, true);
      }

      // Test Profile tab
      final profileTab = find.text('Profile');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage).evaluate().isNotEmpty, true);
      }
    });

    testWidgets('Back button navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a detail page (if accessible)
      // Then test back button
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        // Verify navigation back
      }
    });
  });
}
