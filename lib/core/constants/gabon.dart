// ignore_for_file: constant_identifier_names
// -----------------------------------------------------------------------------
// File: gabon.dart
// Purpose: Defines application-wide constant values, national metadata, and copy
//          specific to Gabon.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

/// Application-wide constants including branding, localization metadata,
/// and Gabon-specific UI copy strings.
class Constants {
  /// The official name of the application displayed across app bars and branding.
  static const String APP_TITLE = 'AGNAMBIE';
  
  // Country Metadata
  /// The name of the target country for localized scripture audio.
  static const String COUNTRY_NAME = 'Gabon';

  /// The emoji flag representing the target country.
  static const String COUNTRY_FLAG = '🇬🇦';
  
  // Tagline / Subtitles
  /// The promotional subtitle / slogan of the application.
  static const String APP_SUBTITLE = 'LA BIBLE AUDIO DU GABON';

  /// The primary headline displayed in the hero section of the home view.
  static const String HERO_TITLE = 'Écoutez la Bible dans votre langue.';

  /// The descriptive body copy displayed in the hero section of the home view.
  static const String HERO_DESCRIPTION = 'Découvrez les Écritures dans les langues du $COUNTRY_NAME.';
}
