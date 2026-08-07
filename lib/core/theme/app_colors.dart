import 'package:flutter/material.dart';

/// The single source of colour for this app. A `Color(0xFF...)` literal
/// anywhere outside this file is a defect (root AGENTS.md §6).
class AppColors {
  const AppColors._();

  // --- Brand greens ---
  // Snapped to the Figma "kids-nursery" file's single accent green
  // (#3b6934) — the file has no formal color styles/variables, so this is
  // the exact hex read directly off the child-profile screen's layers.
  static const Color darkGreen = Color(0xFF3B6934);
  static const Color primaryGreen = Color(0xFF6B9B64);
  static const Color accentGreen = Color(0xFF3B6934);
  static const Color forestGreen = Color(0xFF3B6934);
  static const Color leafGreen = Color(0xFF80B674);
  /// Light end of Figma's brand gradient (`linear-gradient(..., #3b6934 0%, #bcf0ae 100%)`).
  static const Color brandGradientLight = Color(0xFFBCF0AE);

  // --- Semantic ---
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color successTint = Color(0xFFE8F5E9);
  static const Color mintTint = Color(0xFFC8F6C2);
  static const Color dangerRed = Color(0xFFC72424);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color peachTint = Color(0xFFFFDAD6);
  static const Color amberTint = Color(0xFFFFE0B2);
  static const Color penaltyOrange = Color(0xFFE0762E);
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color creamTint = Color(0xFFFDF2E9);
  /// Allergy-tag text red, e.g. "Peanuts"/"Dairy" chips.
  static const Color allergyTagText = Color(0xFF93000A);
  /// Emergency-contact-card label amber ("EMERGENCY CONTACT").
  static const Color amberLabel = Color(0xFF825500);

  // --- Accents ---
  static const Color gold = Color(0xFFB08D5B);
  static const Color bronze = Color(0xFF986847);
  static const Color brown = Color(0xFF795548);
  static const Color brownLight = Color(0xFF8D6E63);
  static const Color brownDark = Color(0xFF6D4C41);
  /// Weekly-plan card border, Figma "kids-nursery" Manage Subscriptions (#805533).
  static const Color subscriptionBrown = Color(0xFF805533);
  /// "ACTIVE" pill badge text on the assign-plan panel.
  static const Color activeBadgeText = Color(0xFF23501E);
  /// "N Active Plans" pill badge background.
  static const Color activePlansBadgeBg = Color(0xFFFFDDB3);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1C1C19);
  static const Color textHeading = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF474747);
  static const Color textTertiary = Color(0xFF8A8A8A);

  // --- Surfaces ---

  /// The single page background for every admin screen. Screens used to each
  /// pick their own near-white (ivory/bone/linen/cream), which read as
  /// mismatched panels when navigating between them — route new screens
  /// through this rather than adding another off-white.
  static const Color surfacePage = surfaceCream;

  static const Color background = Color(0xFFF8F9FA);
  static const Color lightGrey = Color(0xFFFDFDFD);
  static const Color surfaceWhite = Color(0xFFFBFBFB);
  static const Color surfaceIvory = Color(0xFFFAF9F6);
  static const Color surfaceBone = Color(0xFFFAF8F5);
  static const Color surfaceMist = Color(0xFFF9F9F7);
  static const Color surfaceLinen = Color(0xFFFCFBF8);
  static const Color surfaceCream = Color(0xFFF6F3EE);
  static const Color surfaceSand = Color(0xFFF0EDE8);
  static const Color surfaceSmoke = Color(0xFFF2F2F2);
  static const Color surfaceSage = Color(0xFFF0F4EF);
  /// Neutral chip/avatar-placeholder background (emergency-contact icons).
  static const Color neutralChip = Color(0xFFE5E2DD);
  /// Muted calendar-day background (Attendance Log non-highlighted days).
  static const Color calendarMuted = Color(0xFFEBE8E3);

  // --- Daily schedule pastels (per-activity icon-circle backgrounds) ---
  static const Color schedulePastelAmber = Color(0xFFFFF3CD);
  static const Color schedulePastelPeach = Color(0xFFFFE5D9);
  static const Color schedulePastelPink = Color(0xFFFFD6E0);
  static const Color schedulePastelRose = Color(0xFFFFC0CB);
  static const Color schedulePastelBlush = Color(0xFFE8AEB7);
  static const Color schedulePastelSage = Color(0xFFD8E2DC);
  static const Color schedulePastelMint = Color(0xFFD8F3DC);
  static const Color schedulePastelGreen = Color(0xFFB7E4C7);
  static const Color schedulePastelDeepGreen = Color(0xFF95D5B2);
}
