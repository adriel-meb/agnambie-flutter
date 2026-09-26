// -----------------------------------------------------------------------------
// File: bible_brain_source.dart
// Purpose: Concrete implementation of BibleAudioSource communicating with the backend proxy.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/bible_edition.dart';
import '../models/book.dart';
import '../models/language.dart';
import 'bible_audio_source.dart';

/// Concrete implementation of [BibleAudioSource] fetching data from the Go backend.
class BibleBrainSource implements BibleAudioSource {
  /// HTTP client wrapper used for network communication.
  final ApiClient _apiClient;

  /// Creates a [BibleBrainSource] instance with an optional custom [ApiClient].
  ///
  /// If [apiClient] is omitted, the singleton instance of [ApiClient] is used.
  BibleBrainSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Unwraps the `{"data": [...], "meta": ...}` envelope from the backend.
  ///
  /// Extracts the dynamic list contained under the `data` key. Throws a
  /// [DataParsingException] if the response structure is unexpected.
  List<dynamic> _unwrapData(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as List<dynamic>;
    }
    throw const DataParsingException('Response missing "data" envelope');
  }

  /// Fetches the list of all supported languages from the `/api/languages` endpoint.
  ///
  /// Returns a list of [Language] domain models.
  /// Throws an [ApiException] on network or parsing failures.
  @override
  Future<List<Language>> getLanguages() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/api/languages');
      final list = _unwrapData(response);
      return list.map((json) => Language.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Exceptions are already transformed into ApiException by our Dio interceptor;
      // fallback to NetworkException if error object is untyped
      throw e.error as ApiException? ?? const NetworkException('Unknown error');
    }
  }

  /// Fetches available Bible editions for a given language [iso] code via `/api/bibles`.
  ///
  /// Passes `language_code` as query parameter to the backend.
  /// Throws an [ApiException] if the request fails.
  @override
  Future<List<BibleEdition>> getBiblesForLanguage(String iso) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/bibles',
        queryParameters: {'language_code': iso},
      );
      final list = _unwrapData(response);
      return list.map((json) => BibleEdition.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Propagate converted ApiException or default network failure
      throw e.error as ApiException? ?? const NetworkException('Unknown error');
    }
  }

  /// Fetches all books for a specific [bibleId] fileset via `/api/books`.
  ///
  /// Passes `bible_id` query parameter to the backend.
  /// Throws an [ApiException] on failure.
  @override
  Future<List<Book>> getBooks(String bibleId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/books',
        queryParameters: {'bible_id': bibleId},
      );
      final list = _unwrapData(response);
      return list.map((json) => Book.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Propagate converted ApiException or default network failure
      throw e.error as ApiException? ?? const NetworkException('Unknown error');
    }
  }

  /// Fetches the direct playable audio stream URL for a given [bibleId], [bookId], and [chapter].
  ///
  /// Note that [bibleId] corresponds to the specific audio fileset ID.
  /// Queries `/api/audio` and extracts the streaming path from the first audio item.
  /// Throws [NoAudioAvailableException] if no audio tracks or paths are returned.
  @override
  Future<String> getChapterAudioUrl(
    String bibleId,
    String bookId,
    int chapter,
  ) async {
    // Note: To get audio we need the fileset_id, not just the bibleId.
    // Assuming the upper repository layer passes the chosen fileset_id as bibleId here,
    // or we modify the method signature. For now, we map it to fileset_id.
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/audio',
        queryParameters: {
          'fileset_id': bibleId,
          'book': bookId,
          'chapter': chapter,
        },
      );
      final list = _unwrapData(response);
      
      // Verify that the backend returned at least one audio stream record
      if (list.isEmpty) {
        throw const NoAudioAvailableException('No audio found for this chapter');
      }

      // The backend returns an array of audio items. 
      // We grab the path from the first one.
      final firstItem = list.first as Map<String, dynamic>;
      final path = firstItem['path'] as String?;
      
      // Ensure the path string is valid and non-empty
      if (path == null || path.isEmpty) {
        throw const NoAudioAvailableException('Audio URL is empty');
      }
      
      return path;
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const NetworkException('Unknown error');
    }
  }
}
