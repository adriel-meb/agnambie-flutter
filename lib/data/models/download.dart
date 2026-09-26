// -----------------------------------------------------------------------------
// File: download.dart
// Purpose: Defines the data model representing an offline downloaded audio chapter.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

/// Represents an audio chapter downloaded for offline playback.
///
/// Tracks the associated Bible edition, book, chapter number, local file system
/// path, file size in bytes, and the timestamp when it was downloaded.
@immutable
class Download {
  /// Identifier of the Bible edition / fileset associated with the downloaded audio.
  final String bibleId;

  /// Identifier of the biblical book (e.g., "GEN", "MAT").
  final String bookId;

  /// Chapter number of the downloaded recording.
  final int chapter;

  /// Absolute file system path where the audio file is stored locally.
  final String filePath;

  /// File size of the stored audio in bytes.
  final int sizeInBytes;

  /// Date and time when the chapter was downloaded and saved.
  final DateTime downloadedAt;

  /// Optional human-readable version abbreviation (e.g. "LSG", "FC").
  final String? bibleVersion;

  /// Optional full title of the Bible translation (e.g. "Louis Segond 1910").
  final String? bibleName;

  /// Optional language name (e.g. "Fang", "Français").
  final String? language;

  /// Creates an immutable [Download] record representing an offline audio track.
  const Download({
    required this.bibleId,
    required this.bookId,
    required this.chapter,
    required this.filePath,
    required this.sizeInBytes,
    required this.downloadedAt,
    this.bibleVersion,
    this.bibleName,
    this.language,
  });

  // Not an API model, but providing copyWith and basic serialization 
  // is useful for local database (drift/hive/sqflite) mapping later.
  
  /// Creates a copy of this [Download] instance with optional updated fields.
  Download copyWith({
    String? bibleId,
    String? bookId,
    int? chapter,
    String? filePath,
    int? sizeInBytes,
    DateTime? downloadedAt,
    String? bibleVersion,
    String? bibleName,
    String? language,
  }) {
    // Preserve existing field values if no replacement argument is supplied
    return Download(
      bibleId: bibleId ?? this.bibleId,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      filePath: filePath ?? this.filePath,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      bibleVersion: bibleVersion ?? this.bibleVersion,
      bibleName: bibleName ?? this.bibleName,
      language: language ?? this.language,
    );
  }
}
