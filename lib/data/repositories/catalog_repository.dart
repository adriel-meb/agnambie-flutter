// =============================================================================
// File: catalog_repository.dart
// Purpose: Central repository for catalog data including languages, Bibles, books, and chapter audio streams.
// Author: Contributor
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// =============================================================================

import '../models/bible_edition.dart';
import '../models/book.dart';
import '../models/language.dart';
import '../sources/source_registry.dart';

/// The central repository for all catalog data (Languages, Bibles, Books).
/// 
/// UI components (like Riverpod providers) should call this repository instead 
/// of calling the data sources directly. This allows us to add caching, 
/// fallback logic, or app-specific business rules later without breaking the UI.
class CatalogRepository {
  final SourceRegistry _sourceRegistry;

  /// Creates a [CatalogRepository], optionally injecting a custom [SourceRegistry].
  ///
  /// If no [sourceRegistry] is provided, defaults to an instance of [SourceRegistry].
  CatalogRepository({SourceRegistry? sourceRegistry})
      : _sourceRegistry = sourceRegistry ?? SourceRegistry();

  /// Fetches the available languages for the app.
  ///
  /// Queries the active source registry for language entries.
  Future<List<Language>> getLanguages() async {
    // Note: If we had a local cache, we would check it here first.
    // We pass a dummy iso like 'default' because the languages endpoint is global.
    final source = _sourceRegistry.getSourceForLanguage('default');
    
    final languages = await source.getLanguages();
    
    // Future business logic goes here: e.g. filtering out languages with no audio
    return languages;
  }

  /// Fetches the available Bible editions for a specific language [iso] code.
  ///
  /// Queries the source mapped to [iso] to obtain all available editions/translations.
  Future<List<BibleEdition>> getBiblesForLanguage(String iso) async {
    // The registry decides WHICH API to call based on the language ISO.
    final source = _sourceRegistry.getSourceForLanguage(iso);
    return await source.getBiblesForLanguage(iso);
  }

  /// Fetches the list of books for a given [bibleId] (fileset ID).
  ///
  /// Uses [languageIso] to resolve the correct data source, then retrieves
  /// the book collection for [bibleId].
  Future<List<Book>> getBooks(String languageIso, String bibleId) async {
    // Query data source appropriate for language
    final source = _sourceRegistry.getSourceForLanguage(languageIso);
    return await source.getBooks(bibleId);
  }

  /// Fetches the specific audio URL for a given chapter.
  ///
  /// Queries the relevant data source using [languageIso] and resolves the
  /// direct streaming CDN URL for the given [bibleId], [bookId], and [chapter].
  Future<String> getChapterAudioUrl(
    String languageIso,
    String bibleId,
    String bookId,
    int chapter,
  ) async {
    // Resolve provider for the language
    final source = _sourceRegistry.getSourceForLanguage(languageIso);
    
    // Future business logic: fallback from dramatized audio to plain audio
    // could be handled here if the first request fails.
    return await source.getChapterAudioUrl(bibleId, bookId, chapter);
  }
}
