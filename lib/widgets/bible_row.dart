// -----------------------------------------------------------------------------
// File: bible_row.dart
// Purpose: Widget displaying a single Bible translation/edition row item in a list.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../core/constants/gabon.dart';
import '../data/models/bible_edition.dart';

/// A card widget representing an individual Bible edition in a selectable list.
///
/// Displays the edition's abbreviation in a stylized badge, the title/name,
/// country metadata, and an indicator describing whether dramatized or standard
/// audio is available.
class BibleRow extends StatelessWidget {
  /// The Bible edition metadata to display.
  final BibleEdition bible;

  /// Callback executed when the row is tapped by the user.
  final VoidCallback onTap;

  /// Creates a [BibleRow] for the specified [bible] edition and tap handler [onTap].
  const BibleRow({
    super.key,
    required this.bible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    // Determine some display text based on filesets
    // We can infer coverage (Full Bible / NT) and audio type from fileset codes.
    // For now, we'll provide some defaults if we can't parse it exactly,
    // as the real parsing logic would go in the repository later.
    // Check if any fileset contains dramatized audio format
    final hasDramatized = bible.filesets.values.expand((e) => e).any((f) => f.setTypeCode == 'audio_drama');
    final audioText = hasDramatized ? 'Audio dramatisé' : 'Audio standard';

    return Card.outlined(
      shape: themeData.cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Abbreviation Badge - visually distinguishes editions with styled initialism
              Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary, // The forest green
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  bible.abbr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details - title, national metadata, and audio type badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bible.name,
                      style: themeData.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Displays country flag and localized language label
                    Text(
                      '${Constants.COUNTRY_FLAG} ${Constants.COUNTRY_NAME} · ${bible.language}',
                      style: themeData.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    // Indicates whether audio is dramatized or standard narration
                    Text(
                      audioText,
                      style: themeData.textTheme.labelMedium?.copyWith(
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing chevron indicator for navigation affordance
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: themeData.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
