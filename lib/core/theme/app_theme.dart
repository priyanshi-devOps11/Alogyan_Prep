import 'package:flutter/material.dart';

/// Alogyan Prep — complete design token system.
/// ONE file. Every widget imports only this.
/// Token names are consistent across the entire codebase.
abstract class AppTheme {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brandRed        = Color(0xFFE84B1A);
  static const Color brandRedLight   = Color(0xFFFF6B3D);
  static const Color brandRedDark    = Color(0xFFC03A10);
  static const Color brandRedSurface = Color(0xFFFFF0EC);

  // ── Dark background (Scapia-style intro slides) ───────────────────────────
  static const Color bgDark    = Color(0xFF0A0A14);
  static const Color bgDark2   = Color(0xFF12121F);
  static const Color bgDark3   = Color(0xFF1A1A2E);

  // ── Light background (profile-building steps) ────────────────────────────
  static const Color bgWhite   = Color(0xFFFFFFFF);
  static const Color bgSoft    = Color(0xFFF8F7FC);
  static const Color bgCardAlt = Color(0xFFF4F2FF);

  // ── Text on dark ─────────────────────────────────────────────────────────
  static const Color textOnDark          = Color(0xFFF5F5F7);
  static const Color textSecondaryOnDark = Color(0xFFB0B0C8);
  static const Color textMutedOnDark     = Color(0xFF6B6B88);

  // ── Text on light ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B88);
  static const Color textMuted     = Color(0xFFAEAEC8);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderLight  = Color(0xFFEEEDF5);
  static const Color borderDark   = Color(0xFF2E2E4A);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error   = Color(0xFFEF4444);

  // ── Typography ────────────────────────────────────────────────────────────
  static const String fontFamily = 'Poppins';

  // Used on dark slides
  static const TextStyle displayDark = TextStyle(
    fontFamily: fontFamily, fontSize: 34,
    fontWeight: FontWeight.w700, color: textOnDark,
    height: 1.18, letterSpacing: -0.8,
  );
  static const TextStyle bodyOnDark = TextStyle(
    fontFamily: fontFamily, fontSize: 15,
    fontWeight: FontWeight.w400, color: textSecondaryOnDark,
    height: 1.6,
  );
  static const TextStyle titleOnDark = TextStyle(
    fontFamily: fontFamily, fontSize: 14,
    fontWeight: FontWeight.w500, color: textSecondaryOnDark,
  );
  static const TextStyle accentTagDark = TextStyle(
    fontFamily: fontFamily, fontSize: 11,
    fontWeight: FontWeight.w600, color: brandRed,
    letterSpacing: 1.6,
  );

  // Used on light steps
  static const TextStyle displayLight = TextStyle(
    fontFamily: fontFamily, fontSize: 28,
    fontWeight: FontWeight.w700, color: textPrimary,
    height: 1.2, letterSpacing: -0.5,
  );
  static const TextStyle headingLight = TextStyle(
    fontFamily: fontFamily, fontSize: 22,
    fontWeight: FontWeight.w700, color: textPrimary,
  );
  static const TextStyle bodyLight = TextStyle(
    fontFamily: fontFamily, fontSize: 15,
    fontWeight: FontWeight.w400, color: textSecondary,
    height: 1.6,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily, fontSize: 13,
    fontWeight: FontWeight.w400, color: textSecondary,
    height: 1.5,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 13,
    fontWeight: FontWeight.w600, color: textPrimary,
  );
  static const TextStyle stepLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 11,
    fontWeight: FontWeight.w500, color: textMuted,
    letterSpacing: 0.5,
  );
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 15,
    fontWeight: FontWeight.w700, color: Colors.white,
    letterSpacing: 0.2,
  );
  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily, fontSize: 14,
    fontWeight: FontWeight.w600, color: brandRed,
  );

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double s4  = 4.0;
  static const double s8  = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double radiusS      = 8.0;
  static const double radiusM      = 14.0;
  static const double radiusL      = 20.0;
  static const double radiusXL     = 28.0;
  static const double radiusCircle = 999.0;

  // ── Dot indicator (used on dark slides) ───────────────────────────────────
  static const double   dotHeight       = 8.0;
  static const double   dotWidthInactive = 8.0;
  static const double   dotWidthActive  = 28.0;
  static const Color    dotActive       = brandRed;
  static const Color    dotInactive     = Color(0xFF2E2E4A);
  static const Duration dotAnimDuration = Duration(milliseconds: 350);
  static const Curve    dotAnimCurve    = Curves.easeInOutCubic;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
        blurRadius: 20, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(color: brandRed.withValues(alpha: 0.35),
        blurRadius: 20, offset: const Offset(0, 8)),
  ];

  // ── MaterialThemeData (light — used for profile steps) ────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: bgSoft,
    colorScheme: const ColorScheme.light(
      primary: brandRed, surface: bgWhite,
      onSurface: textPrimary, error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: bgWhite,
      hintStyle: bodyLight.copyWith(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: brandRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: bodySmall.copyWith(color: bgWhite),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS)),
    ),
  );
}