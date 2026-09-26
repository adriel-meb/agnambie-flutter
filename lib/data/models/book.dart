// -----------------------------------------------------------------------------
// File: book.dart
// Purpose: Defines the data model representing a biblical book and its chapters.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

/// Represents a book of the Bible within an edition/translation.
///
/// Contains standard identifiers (standard book ID, USFX, and OSIS identifiers),
/// display name, testament classification, book grouping, and available chapters.
@immutable
class Book {
  /// Unique identifier code for the book (e.g., "GEN", "MAT").
  final String bookId;

  /// Unified Standard Format XML (USFX) identifier for the book.
  final String bookIdUsfx;

  /// Open Scriptural Information Standard (OSIS) identifier for the book.
  final String bookIdOsis;

  /// Localized or display name of the book (e.g., "Genèse", "Matthieu").
  final String name;

  /// Testament classification for the book (e.g., "OT" for Old Testament, "NT" for New Testament).
  final String testament;

  /// Group or section to which the book belongs (e.g., "Gospels", "Pentateuch", "Historical").
  final String bookGroup;

  /// List of chapter numbers or chapter metadata objects available for this book.
  final List<dynamic> chapters;

  /// Creates an immutable [Book] instance with all required metadata.
  const Book({
    required this.bookId,
    required this.bookIdUsfx,
    required this.bookIdOsis,
    required this.name,
    required this.testament,
    required this.bookGroup,
    required this.chapters,
  });

  /// Creates a [Book] instance from a JSON map returned by the backend API.
  ///
  /// Extracts identifiers, names, groupings, and chapters while safely falling back
  /// to empty strings or lists if keys are missing or null.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      // Safely cast each property with fallback defaults to guard against null values
      bookId: json['book_id'] as String? ?? '',
      bookIdUsfx: json['book_id_usfx'] as String? ?? '',
      bookIdOsis: json['book_id_osis'] as String? ?? '',
      name: json['name'] as String? ?? '',
      testament: json['testament'] as String? ?? '',
      bookGroup: json['book_group'] as String? ?? '',
      // Default to empty list if the chapters array is missing in payload
      chapters: json['chapters'] as List<dynamic>? ?? [],
    );
  }
}
