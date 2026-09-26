// -----------------------------------------------------------------------------
// File: typography.dart
// Purpose: Configures the typography for the application using Google Fonts.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography configuration for the Agnambie application.
class AppTypography {
  /// Constructs a [TextTheme] with scaled typography using Google Fonts Poppins.
  ///
  /// Applies [primaryText] color for headings and emphasized text,
  /// and [mutedText] for descriptions and secondary metadata.
  static TextTheme buildTextTheme({
    required Color primaryText,
    required Color mutedText,
  }) {
    return TextTheme(
      // Large display headings (hero sections)
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

      // Screen & component titles
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),

      // Standard body
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: mutedText,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 13,
        color: mutedText,
      ),

      // Section overlines and tags (uppercase tracking-widest text)
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: primaryText,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedText,
      ),
    );
  }
}
