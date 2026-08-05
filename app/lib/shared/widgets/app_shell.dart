import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/features/dashboard/presentation/widgets/custom_course_dialog.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/progress')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        return;
      case 1:
        context.go('/explore');
        return;
      case 2:
        context.go('/progress');
        return;
      case 3:
        context.go('/profile');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: child,
      // Massive pink floating action button in the center
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CustomCourseDialog(),
        ),
        backgroundColor: AppColors.neonPink,
        foregroundColor: isDark ? Colors.white : AppColors.strokeLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          side: BorderSide(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: _currentIndex(context) == 0,
                onTap: () => _onTap(context, 0),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: 'EXPLORE',
                isSelected: _currentIndex(context) == 1,
                onTap: () => _onTap(context, 1),
                isDark: isDark,
              ),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'STATS',
                isSelected: _currentIndex(context) == 2,
                onTap: () => _onTap(context, 2),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'PROFILE',
                isSelected: _currentIndex(context) == 3,
                onTap: () => _onTap(context, 3),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.neonPink
                : (isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 1.0,
              color: isSelected
                  ? AppColors.neonPink
                  : (isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
