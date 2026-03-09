import 'package:flutter/material.dart';

/// Pathly Design Tokens — Neon Black + Neon Light
///
/// Neon Black: Deep navy background with glowing pink/green/teal accents
/// Neon Light: Warm cream background with pink/teal accents and pastel cards
abstract final class AppColors {
  // ─── Neon Black Theme ───────────────────────────────────────
  static const neonBlackBg = Color(0xFF131320); // Very dark navy
  static const neonBlackSurface = Color(0xFF1B1B2A); // Card background
  static const neonBlackCard = Color(0xFF26283C); // Inner cards
  static const neonBlackElevated = Color(0xFF2E3048);
  static const strokeDark =
      Color(0xFF0D0D16); // Very dark, almost black strokes

  // ─── Neon Light Theme ───────────────────────────────────────
  static const neonLightBg = Color(0xFFF7F2EC); // Warm cream
  static const neonLightSurface = Color(0xFFFFFFFF);
  static const neonLightCard = Color(0xFFF0EBE5);
  static const neonLightElevated = Color(0xFFE8E3DD);
  static const strokeLight =
      Color(0xFF131320); // Dark navy outline on light mode

  // ─── Accent Colors (shared) ─────────────────────────────────
  static const neonPink = Color(0xFFFF6B9D);
  static const neonPinkLight = Color(0xFFFF94BB);
  static const neonGreen = Color(0xFF51E07B);
  static const neonGreenDark = Color(0xFF3BBD60);
  static const neonTeal = Color(0xFF2BDBCA);
  static const neonYellow = Color(0xFFFFD700);
  static const neonPurple = Color(0xFF9E65FF);

  // ─── Skill Card Pastels (More vibrant for V3/V4) ────────────
  static const pastelPurple = Color(0xFFC7A3FF); // Magic Tricks
  static const pastelPeach = Color(0xFFFFB07B); // Coding Basics
  static const pastelMint = Color(0xFF8CF4AB); // Memory Hacks
  static const pastelBlue = Color(0xFF8CE1FA); // Drawing
  static const pastelPink = Color(0xFFFF8CBE); // Public Speaking
  static const pastelLavender =
      Color(0xFFE4FA9C); // Fitness - Was pastelYellow in design

  // ─── Gamification ───────────────────────────────────────────
  static const xpGold = Color(0xFFFFD740);
  static const streakOrange = Color(0xFFFF5252);
  static const levelGreen = Color(0xFF51E07B);

  // ─── Semantic ───────────────────────────────────────────────
  static const success = Color(0xFF51E07B);
  static const error = Color(0xFFFF5A5A);
  static const warning = Color(0xFFFFCE54);
  static const info = Color(0xFF4FC1E9);

  // ─── Text (Neon Black) ──────────────────────────────────────
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFAAA9B8);
  static const textTertiaryDark = Color(0xFF818096);

  // ─── Text (Neon Light) ──────────────────────────────────────
  static const textPrimaryLight = Color(0xFF12121D);
  static const textSecondaryLight = Color(0xFF5A5868);
  static const textTertiaryLight = Color(0xFF898799);

  // ─── Stats Card Colors ──────────────────────────────────────
  static const statPink = Color(0xFFFF4D6D);
  static const statMint = Color(0xFF00D1B2);
  static const statBlue = Color(0xFF009EEA);

  // ─── Daily Goal card ────────────────────────────────────────
  static const dailyGoalBg = Color(0xFF2E2D12); // Dark olive
  static const dailyGoalBgLight = Color(0xFFFFEFA8); // Light peach/yellow
}
