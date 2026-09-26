// -----------------------------------------------------------------------------
// File: language.dart
// Purpose: Defines the data models representing a language and its filesets.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

/// Represents a spoken language available in the Agnambie catalog.
///
/// Contains language codes, localized and native names, and the collection
/// of available audio filesets for that language.
@immutable
class Language {
  /// ISO language code (e.g., "fan", "myb").
  final String code;

  /// English or standardized international name of the language (e.g., "Fang").
  final String name;

  /// Autonym / native name of the language in the local tongue (e.g., "Faŋ").
  final String nativeName;

  /// List of audio filesets available for this language.
  final List<Fileset> filesets;

  /// Creates an immutable [Language] record with metadata and available filesets.
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.filesets,
  });

  /// Creates a [Language] instance from a JSON map returned by the backend.
  ///
  /// Safely converts the `filesets` array into [Fileset] instances, defaulting to an
  /// empty list if missing.
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nativeName: json['native_name'] as String? ?? '',
      // Safely map fileset entries if present; fall back to an empty list
      filesets: (json['filesets'] as List<dynamic>?)
              ?.map((e) => Fileset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Represents audio metadata and delivery parameters for a specific fileset.
@immutable
class Fileset {
  /// Unique identifier of the fileset (e.g., "FANDBSN2DA").
  final String id;

  /// Alternative fileset ID optimized for low-bandwidth / data-saver modes.
  final String dataSaverId;

  /// Format type of the audio stream (e.g., "audio_drama", "audio").
  final String type;

  /// Audio encoding / codec used (e.g., "mp3", "opus").
  final String codec;

  /// Human-readable description of the fileset.
  final String description;

  /// Scope size indicator (e.g., "NT" for New Testament, "C" for complete Bible).
  final String size;

  /// Creates an immutable [Fileset] with delivery and encoding parameters.
  const Fileset({
    required this.id,
    required this.dataSaverId,
    required this.type,
    required this.codec,
    required this.description,
    required this.size,
  });

  /// Creates a [Fileset] instance from a JSON map.
  factory Fileset.fromJson(Map<String, dynamic> json) {
    return Fileset(
      id: json['id'] as String? ?? '',
      dataSaverId: json['data_saver_id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      codec: json['codec'] as String? ?? '',
      description: json['description'] as String? ?? '',
      size: json['size'] as String? ?? '',
    );
  }
}
