import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/features/auth/presentation/pages/login_page.dart';
import 'package:pathly_app/features/auth/presentation/pages/register_page.dart';
import 'package:pathly_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pathly_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathly_app/features/explore/presentation/pages/explore_page.dart';
import 'package:pathly_app/features/lesson/presentation/pages/lesson_player_page.dart';
import 'package:pathly_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_preview_page.dart';
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_page.dart';
import 'package:pathly_app/shared/widgets/app_shell.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/explore',
          name: 'explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/progress',
          name: 'progress',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Progress — Coming Soon')),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/lesson/:lessonId',
      name: 'lesson',
      builder: (context, state) => LessonPlayerPage(
        lessonId: state.pathParameters['lessonId'] ?? '',
      ),
    ),
    // ── Curriculum routes ──────────────────────────────────────────
    GoRoute(
      path: '/curriculum/preview/:skillName',
      name: 'curriculum-preview',
      builder: (context, state) => RoadmapPreviewPage(
        skillName: Uri.decodeComponent(state.pathParameters['skillName'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/curriculum/roadmap/:jobId',
      name: 'curriculum-roadmap',
      builder: (context, state) => RoadmapPage(
        jobId: state.pathParameters['jobId'] ?? '',
      ),
    ),
  ],
);
