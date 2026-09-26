
// -----------------------------------------------------------------------------
// File: spotlight.dart
// Purpose: Featured spotlight banner widget highlighting primary or trending audio Bible content on the home screen.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// A featured spotlight card displayed on the home screen.
///
/// Highlights special or featured audio Bible releases (such as a dramatized
/// complete Bible) with high visual prominence and quick playback actions.
class Spotlight extends StatelessWidget {
  /// Creates a [Spotlight] widget.
  const Spotlight({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    // Card container styled using the primary theme color to stand out as a hero banner.
    return Card(
      color: themeData.colorScheme.primary,
      shape: themeData.cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge header indicating featured spotlight content.
              Text(
                'À LA UNE',
                style: themeData.textTheme.labelSmall?.copyWith(
                  color: themeData.colorScheme.surface,
                ),
              ),
              // Featured item title.
              Text(
                'Bible en Fang',
                style: themeData.textTheme.displaySmall?.copyWith(
                  color: themeData.colorScheme.surface,
                ),
              ),
              // Subtitle describing audio format and scope.
              Text(
                'Audio dramatisé - Bible complète',
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.surface.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 10),

              // Action button to start playback immediately.
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(themeData.colorScheme.surface),
                  ),
                  onPressed: () => {debugPrint('button pressed')},
                  child: Row(
                    spacing: 9,
                    children: [
                      Icon(Icons.play_arrow, color: themeData.colorScheme.primary),
                      Text(
                        'Commencer',
                        style: themeData.textTheme.titleSmall?.copyWith(
                          color: themeData.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
