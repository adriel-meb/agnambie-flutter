// -----------------------------------------------------------------------------
// File: bible_edition.dart
// Purpose: Defines data models representing a Bible edition and associated filesets.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

/// Represents a specific translation or edition of the Bible.
///
/// Contains edition metadata such as abbreviation, vernacular name, language,
/// ISO code, and a map of filesets grouped by source or format.
@immutable
class BibleEdition {
  /// Unique identifier of the Bible edition in the backend catalog.
  final String id;

  /// Standard short abbreviation for the edition (e.g., "LSG", "FC").
  final String abbr;

  /// Full descriptive name of the Bible edition.
  final String name;

  /// Vernacular name of the Bible in its native language/script.
  final String vname;

  /// Language name associated with this edition (e.g., "Fang", "Français").
  final String language;

  /// ISO 639-3 three-letter language code (e.g., "fan", "fra").
  final String iso;

  /// Grouped map of fileset entries, categorized by media source or key.
  final Map<String, List<FilesetEntry>> filesets;

  /// Creates an immutable [BibleEdition] instance.
  const BibleEdition({
    required this.id,
    required this.abbr,
    required this.name,
    required this.vname,
    required this.language,
    required this.iso,
    required this.filesets,
  });

  /// Creates a [BibleEdition] instance from a JSON payload returned by the backend.
  ///
  /// Parses the nested fileset mapping if present, with safe fallbacks for missing values.
  factory BibleEdition.fromJson(Map<String, dynamic> json) {
    final Map<String, List<FilesetEntry>> parsedFilesets = {};
    if (json['filesets'] != null) {
      final fsMap = json['filesets'] as Map<String, dynamic>;
      // Iterate through each fileset group key (e.g., "dbp-prod") and parse entry lists
      for (final key in fsMap.keys) {
        final list = fsMap[key] as List<dynamic>;
        parsedFilesets[key] = list
            .map((e) => FilesetEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return BibleEdition(
      id: json['id'] as String? ?? '',
      abbr: json['abbr'] as String? ?? '',
      name: json['name'] as String? ?? '',
      vname: json['vname'] as String? ?? '',
      language: json['language'] as String? ?? '',
      iso: json['iso'] as String? ?? '',
      filesets: parsedFilesets,
    );
  }
}

/// Represents an individual audio or text fileset entry associated with a Bible edition.
@immutable
class FilesetEntry {
  /// Unique identifier of the fileset (e.g., "FANDBSN2DA").
  final String id;

  /// Type code indicating the media format (e.g., "audio_drama", "audio").
  final String setTypeCode;

  /// Size code specifying the scope of coverage (e.g., "C" for complete, "NT" for New Testament).
  final String setSizeCode;

  /// Creates an immutable [FilesetEntry] with format and coverage metadata.
  const FilesetEntry({
    required this.id,
    required this.setTypeCode,
    required this.setSizeCode,
  });

  /// Creates a [FilesetEntry] instance from a JSON object.
  factory FilesetEntry.fromJson(Map<String, dynamic> json) {
    return FilesetEntry(
      id: json['id'] as String? ?? '',
      setTypeCode: json['set_type_code'] as String? ?? '',
      setSizeCode: json['set_size_code'] as String? ?? '',
    );
  }
}
