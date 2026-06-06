import 'package:flutter/material.dart';

abstract class AppTheme {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brandOrange = Color(0xFFE84B1A);
  static const Color brandOrangeLight = Color(0xFFFF6B3D);
  static const Color brandOrangeDark = Color(0xFFC03A10);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgCanvas = Color(0xFF0A0A14);
  static const Color bgCard = Color(0xFF12121F);
  static const Color bgSurface = Color(0xFF1A1A2E);
  static const Color bgInput = Color(0xFF16162A);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF6B6B88);
  static const Color textError = Color(0xFFFF6B6B);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderDefault = Color(0xFF2E2E4A);
  static const Color borderFocused = Color(0xFFE84B1A);
  static const Color borderError = Color(0xFFFF6B6B);

  // ── Dots ──────────────────────────────────────────────────────────────────
  static const Color dotActive = Color(0xFFE84B1A);
  static const Color dotInactive = Color(0xFF2E2E4A);

  // ── Typography ────────────────────────────────────────────────────────────
  static const String fontFamily = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.18,
    letterSpacing: -0.8,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
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

  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: brandOrange,
    letterSpacing: 0.1,
  );

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spacingXS = 6.0;
  static const double spacingS = 12.0;
  static const double spacingM = 20.0;
  static const double spacingL = 28.0;
  static const double spacingXL = 40.0;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusCircle = 999.0;

  // ── Dot sizes ─────────────────────────────────────────────────────────────
  static const double dotHeight = 8.0;
  static const double dotWidthInactive = 8.0;
  static const double dotWidthActive = 28.0;
  static const Duration dotAnimDuration = Duration(milliseconds: 350);
  static const Curve dotAnimCurve = Curves.easeInOutCubic;

  // ── Material ThemeData ────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: bgCanvas,
    colorScheme: const ColorScheme.dark(
      primary: brandOrange,
      surface: bgCard,
      onSurface: textPrimary,
      error: textError,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgInput,
      hintStyle: inputHint,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderDefault, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderFocused, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderError, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderError, width: 1.5),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: bgSurface,
      contentTextStyle: bodyRegular,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusS)),
      ),
    ),
  );
}