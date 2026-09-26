// -----------------------------------------------------------------------------
// File: typography.dart
// Purpose: Configures the typography for the application using Google Fonts.
// Author: Placeholder
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Centralized typography configuration for the Agnambie application.
class AppTypography {
  /// Constructs a [TextTheme] with scaled typography using Google Fonts Poppins.
  ///
  /// Applies [primaryText] color for headings and emphasized body text,
  /// and [mutedText] for secondary and supporting descriptions.
  static TextTheme buildTextTheme({
    required Color primaryText,
    required Color mutedText,
  }) {
    return TextTheme(
      // Large headings
      displayLarge: GoogleFonts.poppins(
        fontSize: 39,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: primaryText,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: primaryText,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      // Standard body
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: primaryText),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: mutedText, // Often used for descriptions
      ),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: mutedText),
      // Overlines (uppercase tracking-widest text)
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.8,
        color: AppColors.emerald,
      ),
    );
  }
}
