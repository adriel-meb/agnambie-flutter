// -----------------------------------------------------------------------------
// File: book_names.dart
// Purpose: Provides translations and resolution utilities for biblical book names,
//          mapping USFM identifiers to localized French or native language titles.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

// Utility class providing biblical book name mapping and localization logic.
///
/// Supports USFM (Unified Scripture Format XML) standard 3-letter codes
/// to French canonical titles and filters out raw English fallback labels.
class BookNames {
  /// Mapping of 3-letter USFM book identifiers (e.g., 'GEN', 'MAT') to
  /// their canonical French names across the Old and New Testaments.
  static const Map<String, String> frenchNames = {
    'GEN': 'Genèse',
    'EXO': 'Exode',
    'LEV': 'Lévitique',
    'NUM': 'Nombres',
    'DEU': 'Deutéronome',
    'JOS': 'Josué',
    'JDG': 'Juges',
    'RUT': 'Ruth',
    '1SA': '1 Samuel',
    '2SA': '2 Samuel',
    '1KI': '1 Rois',
    '2KI': '2 Rois',
    '1CH': '1 Chroniques',
    '2CH': '2 Chroniques',
    'EZR': 'Esdras',
    'NEH': 'Néhémie',
    'EST': 'Esther',
    'JOB': 'Job',
    'PSA': 'Psaumes',
    'PRO': 'Proverbes',
    'ECC': 'Ecclésiaste',
    'SNG': 'Cantique des Cantiques',
    'ISA': 'Ésaïe',
    'JER': 'Jérémie',
    'LAM': 'Lamentations',
    'EZK': 'Ézéchiel',
    'DAN': 'Daniel',
    'HOS': 'Osée',
    'JOL': 'Joël',
    'AMO': 'Amos',
    'OBA': 'Abdias',
    'JON': 'Jonas',
    'MIC': 'Michée',
    'NAM': 'Nahum',
    'HAB': 'Habacuc',
    'ZEP': 'Sophonie',
    'HAG': 'Aggée',
    'ZEC': 'Zacharie',
    'MAL': 'Malachie',
    
    'MAT': 'Matthieu',
    'MRK': 'Marc',
    'LUK': 'Luc',
    'JHN': 'Jean',
    'ACT': 'Actes',
    'ROM': 'Romains',
    '1CO': '1 Corinthiens',
    '2CO': '2 Corinthiens',
    'GAL': 'Galates',
    'EPH': 'Éphésiens',
    'PHP': 'Philippiens',
    'COL': 'Colossiens',
    '1TH': '1 Thessaloniciens',
    '2TH': '2 Thessaloniciens',
    '1TI': '1 Timothée',
    '2TI': '2 Timothée',
    'TIT': 'Tite',
    'PHM': 'Philémon',
    'HEB': 'Hébreux',
    'JAS': 'Jacques',
    '1PE': '1 Pierre',
    '2PE': '2 Pierre',
    '1JN': '1 Jean',
    '2JN': '2 Jean',
    '3JN': '3 Jean',
    'JUD': 'Jude',
    'REV': 'Apocalypse',
  };

  /// Set of common English Bible book names used to detect whether an API-provided
  /// title is unlocalized English rather than a native language translation.
  static const Set<String> englishNames = {
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
    '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon',
    'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah',
    'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians',
    '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians',
    '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
    'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'
  };

  /// Returns the local API name if it's genuinely localized (not English, not a raw code).
  /// Otherwise, forcefully translates it into French.
  ///
  /// Parameters:
  /// - [bookId]: The standard 3-letter USFM book code (e.g. 'JHN', 'PSA').
  /// - [apiName]: The optional book name returned by the Bible API endpoint.
  ///
  /// Returns the localized name if available; otherwise returns the French translation
  /// or [bookId] as a fallback.
  static String getBestName(String bookId, {String? apiName}) {
    if (apiName != null && apiName.isNotEmpty) {
      // If the API gives us a name that isn't the raw ID and isn't the raw English name,
      // it means it's localized (Fang, French, etc.) and we should use it!
      if (apiName != bookId && !englishNames.contains(apiName)) {
        return apiName;
      }
    }
    
    // Fallback: translate the USFM ID to French.
    return frenchNames[bookId] ?? (apiName != null && apiName.isNotEmpty ? apiName : bookId);
  }
}
