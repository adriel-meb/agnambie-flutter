// -----------------------------------------------------------------------------
// File: bible_header.dart
// Purpose: Displays the header information for a Bible edition.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/constants/gabon.dart';
import '../../../data/models/bible_edition.dart';

/// A header widget displaying the language, flag, and title of a [BibleEdition].
class BibleHeader extends StatelessWidget {
  /// The Bible edition whose info is displayed.
  final BibleEdition bible;

  /// Creates a [BibleHeader] for the given [bible] edition.
  const BibleHeader({super.key, required this.bible});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flag and language banner
        Text(
          '${Constants.COUNTRY_FLAG} ${bible.language}',
          style: themeData.textTheme.labelSmall?.copyWith(
            color: themeData.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        // Bible edition title
        Text(
          bible.name,
          style: themeData.textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        // Optional detail text mapping coverage and audio type
        Text(
          'Audio · Bible complète', // Placeholder mapping text
          style: themeData.textTheme.bodySmall,
        ),
      ],
    );
  }
}
