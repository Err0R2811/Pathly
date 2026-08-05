import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pathly_app/main.dart' as app;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathly_app/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Integration Tests', () {
    setUp(() async {
      // Clear auth state before each test
      await Hive.initFlutter();
      await Hive.openBox<String>('auth_token');
      await Hive.openBox<String>('current_user');
    });

    tearDown(() async {
      // Clean up after each test
      await Hive.deleteBoxFromDisk('auth_token');
      await Hive.deleteBoxFromDisk('current_user');
    });

    testWidgets('User can register successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to register page
      final registerButton = find.text('Sign Up');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
      }

      // Fill in registration form
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      // Submit registration
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify successful registration (should navigate to dashboard or onboarding)
      expect(
        find.byType(DashboardPage).evaluate().isNotEmpty || 
        find.byType(OnboardingPage).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('User can login with valid credentials', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login page
      final loginButton = find.text('Log In');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Fill in login form
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      // Submit login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(
        find.byType(DashboardPage).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Login fails with invalid credentials', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login page
      final loginButton = find.text('Log In');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Fill in invalid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      
      // Submit login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Invalid credentials').evaluate().isNotEmpty, true);
    });

    testWidgets('User can logout', (WidgetTester tester) async {
      // First login
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login and authenticate
      final loginButton = find.text('Log In');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify returned to login screen
      expect(find.text('Log In').evaluate().isNotEmpty, true);
    });
  });
}
