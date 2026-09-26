// Purpose: List item widget representing a language and navigating to its available translations.
// Author: [Author Placeholder]
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter/material.dart';

import '../../data/models/language.dart';
import '../translations/translations_screen.dart';

/// A card widget displaying summary information for a single [Language].
///
/// Tapping the card navigates the user to [TranslationsScreen] for the selected language.
class LanguageCard extends StatelessWidget {
  /// The [Language] model instance containing metadata and filesets to display.
  final Language language;

  /// Creates a [LanguageCard] widget for the given [language].
  const LanguageCard({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Card.outlined(
      shape: themeData.cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Navigate to the translations list screen for the tapped language.
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => TranslationsScreen(language: language)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.language_rounded, color: themeData.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),

              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName, // Native name is bold in prototype
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    // Format pluralized count of available audio Bible filesets.
                    Text(
                      language.filesets.length > 1
                          ? '${language.filesets.length} Bibles audio'
                          : '${language.filesets.length} Bible audio',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Trailing chevron
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
