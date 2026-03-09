import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/theme/app_theme.dart';
import 'package:pathly_app/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  await Hive.openBox<String>('auth_token');
  await Hive.openBox<String>('current_user');
  await Hive.openBox<String>('onboarding_preferences');
  
  runApp(
    const ProviderScope(
      child: PathlyApp(),
    ),
  );
}

class PathlyApp extends ConsumerWidget {
  const PathlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pathly',
      debugShowCheckedModeBanner: false,
      // ─── Neon Black (dark) as default, toggle via provider later ───
      theme: AppTheme.neonLight,
      darkTheme: AppTheme.neonBlack,
      themeMode: ThemeMode.dark, // Default: Neon Black
      routerConfig: goRouter,
    );
  }
}
