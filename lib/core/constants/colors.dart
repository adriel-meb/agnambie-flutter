// -----------------------------------------------------------------------------
// File: colors.dart
// Purpose: Defines the color palette for both light and dark themes.
// Author: Placeholder
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Centralized color palette for the Agnambie application.
class AppColors {
  // ─── Shared Colors ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF173D2B);
  static const Color emerald = Color(0xFF047857);
  static const Color playerBackground = Color(0xFF14271D);

  // ─── Light Mode Colors ──────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFAF9F5);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0C0A09); // stone-950
  static const Color lightTextMuted = Color(0xFF78716C); // stone-500
  static const Color lightBorder = Color(0xFFE7E5E4); // stone-200
  static const Color lightAppBarBlur = Color(0xF2FAF9F5);
  static const Color lightNavUnselected = Color(0xFFA8A29E); // stone-400

  // ─── Dark Mode Colors ───────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0E1B14);
  static const Color darkSurface = Color(0xFF17271E);
  static const Color darkTextPrimary = Color(0xFFF5F5F4); // stone-100
  static const Color darkTextMuted = Color(0xFFA8B5AD);
  static const Color darkBorder = Color(0xFF2A4135);
  static const Color darkAppBarBlur = Color(0xF20E1B14);
}
