import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/theme/app_colors.dart';

class AppTheme {
  // ─── Neon Black (Dark) Theme ────────────────────────────────
  static ThemeData get neonBlack => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.neonBlackBg,
        primaryColor: AppColors.neonPink,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonPink,
          secondary: AppColors.neonGreen,
          tertiary: AppColors.neonTeal,
          surface: AppColors.neonBlackSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: AppColors.textPrimaryDark,
        ),
        cardTheme: CardThemeData(
          color: AppColors.neonBlackCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            side: const BorderSide(
              color: AppColors.strokeDark,
              width: AppConstants.cardBorderWidth,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.neonBlackSurface,
          selectedItemColor: AppColors.neonPink,
          unselectedItemColor: AppColors.textTertiaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neonBlackCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.strokeDark,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.strokeDark,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.neonPink,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: GoogleFonts.inter(
            color: AppColors.textTertiaryDark,
            fontSize: 16,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      );

  // ─── Neon Light Theme ───────────────────────────────────────
  static ThemeData get neonLight => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.neonLightBg,
        primaryColor: AppColors.neonPink,
        colorScheme: const ColorScheme.light(
          primary: AppColors.neonPink,
          secondary: AppColors.neonTeal,
          tertiary: AppColors.neonGreen,
          surface: AppColors.neonLightSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryLight,
        ),
        cardTheme: CardThemeData(
          color: AppColors.neonLightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            side: const BorderSide(
              color: AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.neonLightSurface,
          selectedItemColor: AppColors.neonPink,
          unselectedItemColor: AppColors.textTertiaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neonLightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            borderSide: const BorderSide(
              color: AppColors.neonPink,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: GoogleFonts.inter(
            color: AppColors.textTertiaryLight,
            fontSize: 16,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      );
}
