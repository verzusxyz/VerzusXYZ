import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerzusColors {
  // VerzusXYZ Brand Colors - Modern Gaming Palette
  static const primaryPurple = Color(0xFF6366F1); // Indigo-600
  static const primaryPurpleLight = Color(0xFF8B5CF6); // Violet-500
  static const accentGreen = Color(0xFF10B981); // Emerald-500
  static const accentOrange = Color(0xFFF59E0B); // Amber-500
  static const dangerRed = Color(0xFFEF4444); // Red-500
  static const warningYellow = Color(0xFFFBBF24); // Yellow-400
  
  // Light Mode
  static const lightBackground = Color(0xFFFAFBFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF3F4F6);
  static const lightOnSurface = Color(0xFF111827);
  static const lightOnSurfaceVariant = Color(0xFF6B7280);
  
  // Dark Mode  
  static const darkBackground = Color(0xFF0F172A); // Slate-900
  static const darkSurface = Color(0xFF1E293B); // Slate-800
  static const darkSurfaceVariant = Color(0xFF334155); // Slate-700
  static const darkOnSurface = Color(0xFFF8FAFC); // Slate-50
  static const darkOnSurfaceVariant = Color(0xFFCBD5E1); // Slate-300
}


class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: VerzusColors.primaryPurple,
    onPrimary: Colors.white,
    primaryContainer: VerzusColors.primaryPurpleLight.withValues(alpha: 0.1),
    onPrimaryContainer: VerzusColors.primaryPurple,
    secondary: VerzusColors.accentGreen,
    onSecondary: Colors.white,
    tertiary: VerzusColors.accentOrange,
    onTertiary: Colors.white,
    error: VerzusColors.dangerRed,
    onError: Colors.white,
    surface: VerzusColors.lightSurface,
    onSurface: VerzusColors.lightOnSurface,
    surfaceContainerHighest: VerzusColors.lightSurfaceVariant,
    onSurfaceVariant: VerzusColors.lightOnSurfaceVariant,
    outline: VerzusColors.lightOnSurfaceVariant.withValues(alpha: 0.3),
  ),
  scaffoldBackgroundColor: VerzusColors.lightBackground,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: VerzusColors.lightSurface,
    foregroundColor: VerzusColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: VerzusColors.primaryPurpleLight,
    onPrimary: VerzusColors.darkBackground,
    primaryContainer: VerzusColors.primaryPurple.withValues(alpha: 0.2),
    onPrimaryContainer: VerzusColors.primaryPurpleLight,
    secondary: VerzusColors.accentGreen,
    onSecondary: VerzusColors.darkBackground,
    tertiary: VerzusColors.accentOrange,
    onTertiary: VerzusColors.darkBackground,
    error: VerzusColors.dangerRed,
    onError: Colors.white,
    surface: VerzusColors.darkSurface,
    onSurface: VerzusColors.darkOnSurface,
    surfaceContainerHighest: VerzusColors.darkSurfaceVariant,
    onSurfaceVariant: VerzusColors.darkOnSurfaceVariant,
    outline: VerzusColors.darkOnSurfaceVariant.withValues(alpha: 0.3),
  ),
  scaffoldBackgroundColor: VerzusColors.darkBackground,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: VerzusColors.darkSurface,
    foregroundColor: VerzusColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);
