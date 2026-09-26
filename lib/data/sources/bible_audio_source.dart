// -----------------------------------------------------------------------------
// File: bible_audio_source.dart
// Purpose: Abstract interface defining the contract for Bible audio data sources.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import '../models/bible_edition.dart';
import '../models/book.dart';
import '../models/language.dart';

/// The contract that any audio provider (e.g., Bible Brain) must fulfill.
///
/// Defines methods for querying catalog data (languages, Bible translations,
/// and books) as well as obtaining streaming audio URLs for specific chapters.
abstract class BibleAudioSource {
  /// Fetches a list of available languages.
  Future<List<Language>> getLanguages();

  /// Fetches a list of Bibles available for a specific language [iso] code.
  Future<List<BibleEdition>> getBiblesForLanguage(String iso);

  /// Fetches the list of books for a given [bibleId].
  Future<List<Book>> getBooks(String bibleId);

  /// Fetches the specific audio URL for a given [bibleId], [bookId], and [chapter].
  Future<String> getChapterAudioUrl(String bibleId, String bookId, int chapter);
}
