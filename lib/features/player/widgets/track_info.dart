// File: track_info.dart
// Purpose: Displays the artwork and details of the current track.
// Author: Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26

import 'package:flutter/material.dart';

import '../../../core/constants/gabon.dart';
import '../../../core/utils/book_names.dart';
import '../player_controller.dart';

/// A widget displaying the artwork and metadata for the given [track].
class TrackInfo extends StatelessWidget {
  /// The metadata of the currently playing track.
  final TrackMetadata track;

  /// Creates a [TrackInfo] instance.
  const TrackInfo({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Artwork placeholder
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFfacc15),
                  Color(0xFF047857),
                  Color(0xFF07130c)
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 15),
                )
              ],
            ),
            child: const Icon(Icons.menu_book_rounded,
                size: 80, color: Colors.white),
          ),
        ),
        const SizedBox(height: 40),

        // Title and Info
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Constants.COUNTRY_FLAG} ${track.languageIso} · ${track.bibleId}',
                style: const TextStyle(
                  color: Color(0xFF6ee7b7), // Emerald 300
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                BookNames.getBestName(track.bookId, apiName: track.bookName),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chapitre ${track.chapter}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
