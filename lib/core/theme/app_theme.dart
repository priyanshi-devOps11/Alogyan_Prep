import 'package:flutter/material.dart';

/// Central token source for the Alogyan Prep design system.
///
/// All colours, typography sizes, spacing, and durations live here.
/// Never hardcode values inside widgets — always reference [AppTheme].
abstract class AppTheme {
  // ── Brand Colours ────────────────────────────────────────────────────────────
  static const Color brandOrange = Color(0xFFE84B1A);
  static const Color brandOrangeLight = Color(0xFFFF6B3D);
  static const Color brandOrangeDark = Color(0xFFC03A10);

  static const Color backgroundDark = Color(0xFF0A0A14);
  static const Color backgroundCard = Color(0xFF12121F);
  static const Color surfaceColor = Color(0xFF1A1A2E);

  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF6B6B88);

  static const Color dotInactive = Color(0xFF2E2E4A);
  static const Color dotActive = Color(0xFFE84B1A);

  static const Color shimmerBase = Color(0xFF1E1E35);
  static const Color shimmerHighlight = Color(0xFF2A2A45);

  // ── Typography ───────────────────────────────────────────────────────────────
  static const String fontFamily = 'Poppins'; // Add to pubspec.yaml

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.18,
    letterSpacing: -0.8,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: brandOrange,
    letterSpacing: 1.6,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 0.3,
  );

  // ── Spacing ──────────────────────────────────────────────────────────────────
  static const double paddingXS = 6.0;
  static const double paddingS = 12.0;
  static const double paddingM = 20.0;
  static const double paddingL = 28.0;
  static const double paddingXL = 40.0;

  // ── Radii ────────────────────────────────────────────────────────────────────
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusCircle = 999.0;

  // ── Animation ────────────────────────────────────────────────────────────────
  static const Duration dotAnimDuration = Duration(milliseconds: 350);
  static const Curve dotAnimCurve = Curves.easeInOutCubic;

  // ── Dot sizes ────────────────────────────────────────────────────────────────
  static const double dotHeight = 8.0;
  static const double dotWidthInactive = 8.0;
  static const double dotWidthActive = 28.0;
}
