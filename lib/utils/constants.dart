import 'package:flutter/material.dart';

class AppConstants {
  // Grid
  static const int gridSize = 9;
  static const double gridSpacing = 2.0;
  static const double gridBorderRadius = 16.0;
  static const double cellBorderRadius = 4.0;

  // Animation Durations
  static const Duration placementDuration = Duration(milliseconds: 200);
  static const Duration clearDuration = Duration(milliseconds: 400);
  static const Duration scoreDuration = Duration(milliseconds: 600);
  static const Duration comboDuration = Duration(milliseconds: 800);
  static const Duration gameOverDuration = Duration(milliseconds: 500);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Duration pieceTrayDuration = Duration(milliseconds: 300);

  // Scoring
  static const int placeBlockScore = 5;
  static const List<int> lineClearScores = [0, 100, 250, 450, 700, 1000, 1350, 1750, 2200];

  // Drag
  static const double dragScale = 1.1;
  static const double dragElevation = 12.0;
  static const double pieceTrayScale = 0.7;

  // Storage Keys
  static const String highScoreKey = 'high_score';
  static const String soundEnabledKey = 'sound_enabled';
  static const String musicEnabledKey = 'music_enabled';
  static const String hapticEnabledKey = 'haptic_enabled';
  static const String animationsEnabledKey = 'animations_enabled';
  static const String themeKey = 'theme_mode';
  static const String tutorialShownKey = 'tutorial_shown';
}

class AppColors {
  // Background Gradient
  static const Color bgDark = Color(0xFF0A0E1F);
  static const Color bgMid = Color(0xFF11152B);
  static const Color bgLight = Color(0xFF1A2042);

  // Grid
  static const Color gridBg = Color(0xFF0D1225);
  static const Color gridBorder = Color(0xFF1E2548);
  static const Color cellEmpty = Color(0xFF151B35);
  static const Color cellBorder = Color(0xFF1A2145);

  // Block Colors
  static const List<BlockColorSet> blockColors = [
    BlockColorSet(Color(0xFFFF6B6B), Color(0xFFEE5A5A), Color(0xFFFF8A8A), Color(0xFFCC4444)), // Coral
    BlockColorSet(Color(0xFFFF9F43), Color(0xFFEE8E32), Color(0xFFFFB86B), Color(0xFFCC7722)), // Orange
    BlockColorSet(Color(0xFFFECA57), Color(0xFFEDB946), Color(0xFFFFDD7F), Color(0xFFCCA030)), // Yellow
    BlockColorSet(Color(0xFF48DBAB), Color(0xFF37CA9A), Color(0xFF70E8C3), Color(0xFF28A87A)), // Green
    BlockColorSet(Color(0xFF45B7D1), Color(0xFF34A6C0), Color(0xFF6DD4E8), Color(0xFF2288A8)), // Cyan
    BlockColorSet(Color(0xFF6C5CE7), Color(0xFF5B4BD6), Color(0xFF8E80EF), Color(0xFF4430BB)), // Blue/Indigo
    BlockColorSet(Color(0xFFA29BFE), Color(0xFF918AED), Color(0xFFBCB6FF), Color(0xFF7068CC)), // Purple
    BlockColorSet(Color(0xFFFD79A8), Color(0xFFEC6897), Color(0xFFFE9BC0), Color(0xFFCC5080)), // Pink
  ];

  // UI
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D4);
  static const Color textAccent = Color(0xFFFECA57);
  static const Color validPlacement = Color(0x4048DBAB);
  static const Color invalidPlacement = Color(0x40FF6B6B);
  static const Color buttonBg = Color(0xFF1E2548);
  static const Color buttonGlow = Color(0xFF6C5CE7);
  static const Color overlayBg = Color(0xCC0A0E1F);
}

class BlockColorSet {
  final Color main;
  final Color dark;
  final Color light;
  final Color shadow;

  const BlockColorSet(this.main, this.dark, this.light, this.shadow);
}

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static const TextStyle title = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: 4,
    color: AppColors.textPrimary,
  );

  static const TextStyle score = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle scoreLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    color: AppColors.textSecondary,
  );

  static const TextStyle combo = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textAccent,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle instruction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontStyle: FontStyle.italic,
  );
}
