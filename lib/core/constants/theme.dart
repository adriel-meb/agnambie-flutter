// -----------------------------------------------------------------------------
// File: theme.dart
// Purpose: Configures light and dark visual themes for the Agnambie application.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'typography.dart';

/// The visual theme builder for Agnambie, derived from the Sauti Gabon design system.
class AppTheme {
  /// Background color utilized for the dedicated audio player view.
  static const Color playerBackground = AppColors.playerBackground;

  /// Generates the light mode [ThemeData] using warm off-white surfaces,
  /// emerald/forest green brand highlights, and flat cards with subtle borders.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.emerald,
        surface: AppColors.lightBg,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainer: AppColors.lightSurface,
        outline: AppColors.lightBorder,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: AppTypography.buildTextTheme(
        primaryText: AppColors.lightTextPrimary,
        mutedText: AppColors.lightTextMuted,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightAppBarBlur,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightAppBarBlur,
        elevation: 0,
        selectedItemColor: AppColors.emerald,
        unselectedItemColor: AppColors.lightNavUnselected,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      iconTheme: const IconThemeData(color: AppColors.primary, size: 20),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.lightTextMuted,
        ),
      ),
    );
  }

  /// Generates the dark mode [ThemeData] using deep green surfaces,
  /// emerald highlights, and high-contrast light typography.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.emerald,
        surface: AppColors.darkBg,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainer: AppColors.darkSurface,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: AppTypography.buildTextTheme(
        primaryText: AppColors.darkTextPrimary,
        mutedText: AppColors.darkTextMuted,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkAppBarBlur,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkAppBarBlur,
        elevation: 0,
        selectedItemColor: AppColors.emerald,
        unselectedItemColor: AppColors.darkTextMuted,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 20),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextMuted,
        ),
      ),
    );
  }
}
