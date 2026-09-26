// File: books_providers.dart
// Purpose: Defines Riverpod providers and parameter models for fetching Bible books.
// Author: Adriel
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/book.dart';
import '../../data/repositories/providers.dart';

/// Encapsulates the request parameters needed to fetch books for a specific Bible.
///
/// Contains [languageIso] and [bibleId] to identify the target translation.
/// Implements value equality to serve as a reliable cache key for Riverpod family providers.
class BooksRequest {
  /// The ISO 639-3 language code (e.g., 'fra', 'fan').
  final String languageIso;

  /// The unique identifier or abbreviation for the Bible edition.
  final String bibleId;

  /// Creates a [BooksRequest] with the given [languageIso] and [bibleId].
  const BooksRequest({required this.languageIso, required this.bibleId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooksRequest &&
          runtimeType == other.runtimeType &&
          languageIso == other.languageIso &&
          bibleId == other.bibleId;

  @override
  int get hashCode => languageIso.hashCode ^ bibleId.hashCode;
}

/// Fetches the list of books for a given language ISO and Bible ID.
///
/// Watches [catalogRepositoryProvider] and retrieves the books associated
/// with the provided [BooksRequest].
final booksProvider = FutureProvider.family<List<Book>, BooksRequest>((ref, request) async {
  // Retrieve the catalog repository instance
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  // Fetch books for the specified language ISO and Bible identifier
  return catalogRepo.getBooks(request.languageIso, request.bibleId);
});
