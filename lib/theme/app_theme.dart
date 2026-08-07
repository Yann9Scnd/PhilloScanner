import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color outlineVariant = Color(0xFFC0C7CF);

  static const Color primary = Color(0xFF003B58);
  static const Color primaryContainer = Color(0xFF00537A);
  static const Color primaryFixed = Color(0xFFCAE6FF);
  static const Color primaryFixedDim = Color(0xFF92CDFA);
  static const Color onPrimaryContainer = Color(0xFF8BC6F3);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF835500);
  static const Color secondaryContainer = Color(0xFFFEAA13);
  static const Color secondaryFixed = Color(0xFFFFDDB4);
  static const Color onSecondaryContainer = Color(0xFF694300);
  static const Color onSecondaryFixedVariant = Color(0xFF633F00);

  static const Color tertiary = Color(0xFF003D48);
  static const Color tertiaryContainer = Color(0xFF035664);
  static const Color tertiaryFixed = Color(0xFFADEDFE);
  static const Color tertiaryFixedDim = Color(0xFF91D0E1);
  static const Color onTertiaryContainer = Color(0xFF8AC9DA);
  static const Color onTertiaryFixed = Color(0xFF001F26);
  static const Color onTertiaryFixedVariant = Color(0xFF004E5C);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF41484E);
  static const Color outline = Color(0xFF71787F);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headlineSm({Color color = AppColors.primary}) =>
      GoogleFonts.inter(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: color);

  static TextStyle headlineLgMobile({Color color = AppColors.primary}) =>
      GoogleFonts.inter(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w600, color: color);

  static TextStyle titleLg({Color color = AppColors.primary}) =>
      GoogleFonts.inter(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w500, color: color);

  static TextStyle titleMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(fontSize: 16, height: 24 / 16, letterSpacing: 0.15, fontWeight: FontWeight.w600, color: color);

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(fontSize: 14, height: 20 / 14, letterSpacing: 0.25, fontWeight: FontWeight.w400, color: color);

  static TextStyle labelLg({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(fontSize: 14, height: 20 / 14, letterSpacing: 0.1, fontWeight: FontWeight.w500, color: color);

  static TextStyle labelMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(fontSize: 12, height: 16 / 12, letterSpacing: 0.5, fontWeight: FontWeight.w500, color: color);

  static TextStyle dataDisplay({Color color = AppColors.primary}) =>
      GoogleFonts.inter(fontSize: 36, height: 44 / 36, letterSpacing: -1, fontWeight: FontWeight.w700, color: color);
}

class AppTheme {
  AppTheme._();

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          onSurface: AppColors.onSurface,
        ),
      );
}
