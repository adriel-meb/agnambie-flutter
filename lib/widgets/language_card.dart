// -----------------------------------------------------------------------------
// File: language_card.dart
// Purpose: Reusable card widget for presenting language options in the catalog.
// Author: Agnambie Team
// Creation date: 2026-09-24
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../data/models/language.dart';
import '../features/translations/translations_screen.dart';

/// A card widget that displays information for a specific [Language].
///
/// Shows the native name, number of available audio Bibles, and navigates
/// to the translations screen when tapped.
class LanguageCard extends StatelessWidget {
  /// The language data model to display.
  final Language language;

  /// Creates a [LanguageCard] for the given [language].
  const LanguageCard({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Card.outlined(
      shape: themeData.cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to the translations screen for the selected language
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => TranslationsScreen(language: language),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular leading icon with primary color tint
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.language_rounded,
                  color: themeData.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Text details: native language name and audio count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName, // Native name is bold in catalog list
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    // Singular/plural formatting depending on fileset count
                    Text(
                      language.filesets.length > 1
                          ? '${language.filesets.length} Bibles audio'
                          : '${language.filesets.length} Bible audio',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Trailing chevron indicating navigation
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
