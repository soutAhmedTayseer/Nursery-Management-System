import 'package:flutter/material.dart';

/// The single source of colour for this app. A `Color(0xFF...)` literal
/// anywhere outside this file is a defect (root AGENTS.md §6).
class AppColors {
  const AppColors._();

  // --- Brand greens ---
  static const Color darkGreen = Color(0xFF2D5A27);
  static const Color primaryGreen = Color(0xFF6B9B64);
  static const Color accentGreen = Color(0xFF4A7A3A);
  static const Color forestGreen = Color(0xFF386A41);
  static const Color leafGreen = Color(0xFF80B674);

  // --- Semantic ---
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color successTint = Color(0xFFE8F5E9);
  static const Color mintTint = Color(0xFFC8F6C2);
  static const Color dangerRed = Color(0xFFC72424);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color peachTint = Color(0xFFFFDBCF);
  static const Color amberTint = Color(0xFFFFE0B2);
  static const Color creamTint = Color(0xFFFDF2E9);

  // --- Accents ---
  static const Color gold = Color(0xFFB08D5B);
  static const Color bronze = Color(0xFF986847);
  static const Color brown = Color(0xFF795548);
  static const Color brownLight = Color(0xFF8D6E63);
  static const Color brownDark = Color(0xFF6D4C41);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1C19);
  static const Color textHeading = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF5D5D5D);
  static const Color textTertiary = Color(0xFF8A8A8A);

  // --- Surfaces ---
  static const Color background = Color(0xFFF8F9FA);
  static const Color lightGrey = Color(0xFFFDFDFD);
  static const Color surfaceWhite = Color(0xFFFBFBFB);
  static const Color surfaceIvory = Color(0xFFFAF9F6);
  static const Color surfaceBone = Color(0xFFFAF8F5);
  static const Color surfaceMist = Color(0xFFF9F9F7);
  static const Color surfaceLinen = Color(0xFFFCFBF8);
  static const Color surfaceCream = Color(0xFFF7F6F2);
  static const Color surfaceSand = Color(0xFFF4F2EC);
  static const Color surfaceSmoke = Color(0xFFF2F2F2);
  static const Color surfaceSage = Color(0xFFF0F4EF);
}
