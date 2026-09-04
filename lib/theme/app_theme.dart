import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F4F8);
  static const Color surfaceContainerLow = Color(0xFFF4F7FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceVariant = Color(0xFFEDF2F7);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  static const Color primary = Color(0xFF00537A);
  static const Color primaryContainer = Color(0xFF00537A);
  static const Color primaryFixed = Color(0xFFD6F2FE);
  static const Color primaryFixedDim = Color(0xFFA8E8F9);
  static const Color onPrimaryContainer = Color(0xFFA8E8F9);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFF5A201);
  static const Color secondaryContainer = Color(0xFFFFF3D6);
  static const Color secondaryFixed = Color(0xFFFFE7BA);
  static const Color onSecondaryContainer = Color(0xFF8A5A00);
  static const Color onSecondaryFixedVariant = Color(0xFF633F00);

  static const Color tertiary = Color(0xFFA8E8F9);
  static const Color tertiaryContainer = Color(0xFF00537A);
  static const Color tertiaryFixed = Color(0xFFA8E8F9);
  static const Color tertiaryFixedDim = Color(0xFF75D7EF);
  static const Color onTertiaryContainer = Color(0xFFA8E8F9);
  static const Color onTertiaryFixed = Color(0xFF00273A);
  static const Color onTertiaryFixedVariant = Color(0xFF004363);
  static const Color onTertiary = Color(0xFF00293C);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color onBackground = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFF94A3B8);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headlineSm({Color color = AppColors.primary}) =>
      GoogleFonts.poppins(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, color: color);

  static TextStyle headlineLgMobile({Color color = AppColors.primary}) =>
      GoogleFonts.poppins(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w800, color: color);

  static TextStyle titleLg({Color color = AppColors.primary}) =>
      GoogleFonts.poppins(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700, color: color);

  static TextStyle titleMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.poppins(fontSize: 16, height: 24 / 16, letterSpacing: 0.15, fontWeight: FontWeight.w700, color: color);

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.poppins(fontSize: 14, height: 20 / 14, letterSpacing: 0.25, fontWeight: FontWeight.w500, color: color);

  static TextStyle labelLg({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.poppins(fontSize: 14, height: 20 / 14, letterSpacing: 0.1, fontWeight: FontWeight.w600, color: color);

  static TextStyle labelMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.poppins(fontSize: 12, height: 16 / 12, letterSpacing: 0.5, fontWeight: FontWeight.w600, color: color);

  static TextStyle dataDisplay({Color color = AppColors.primary}) =>
      GoogleFonts.poppins(fontSize: 36, height: 44 / 36, letterSpacing: -1, fontWeight: FontWeight.w800, color: color);
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
