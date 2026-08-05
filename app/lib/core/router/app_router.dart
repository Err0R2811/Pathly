import 'package:go_router/go_router.dart';
import 'package:pathly_app/features/auth/presentation/pages/login_page.dart';
import 'package:pathly_app/features/auth/presentation/pages/register_page.dart';
import 'package:pathly_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pathly_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathly_app/features/explore/presentation/pages/explore_page.dart';
import 'package:pathly_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pathly_app/features/progress/presentation/pages/progress_page.dart';
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_preview_page.dart';
import 'package:pathly_app/features/curriculum/presentation/pages/roadmap_page.dart';
import 'package:pathly_app/features/lessons/presentation/pages/lesson_list_page.dart';
import 'package:pathly_app/features/lessons/presentation/pages/lesson_detail_page.dart';
import 'package:pathly_app/features/lessons/presentation/pages/quiz_page.dart';
import 'package:pathly_app/features/achievements/presentation/pages/badges_page.dart';
import 'package:pathly_app/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:pathly_app/features/search/presentation/pages/search_page.dart';
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
          builder: (context, state) => const ProgressPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/badges',
          name: 'badges',
          builder: (context, state) => const BadgesPage(),
        ),
        GoRoute(
          path: '/leaderboard',
          name: 'leaderboard',
          builder: (context, state) => const LeaderboardPage(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchPage(),
        ),
      ],
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
    GoRoute(
      path: '/roadmap/:roadmapId',
      name: 'saved-roadmap',
      builder: (context, state) => RoadmapPage(
        roadmapId: state.pathParameters['roadmapId'] ?? '',
      ),
    ),
    // ── Lesson routes ───────────────────────────────────────────────
    GoRoute(
      path: '/lessons/:moduleId',
      name: 'lessons',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return LessonListPage(
          moduleId: state.pathParameters['moduleId'] ?? '',
          moduleName: extra['moduleName'] as String? ?? 'Module',
        );
      },
    ),
    GoRoute(
      path: '/lesson/:lessonId',
      name: 'lesson',
      builder: (context, state) => LessonDetailPage(
        lessonId: state.pathParameters['lessonId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/modules/:moduleId/quiz',
      name: 'quiz',
      builder: (context, state) => QuizPage(
        moduleId: state.pathParameters['moduleId'] ?? '',
      ),
    ),
  ],
);
