// File: fileset_utils.dart
// Purpose: Utilities for determining the best fileset ID for audio playback.
// Author: Placeholder
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import '../../../data/models/bible_edition.dart';
import '../../../data/models/book.dart';

/// Extension to help resolve the correct fileset ID for playback.
extension BibleEditionFileset on BibleEdition {
  /// Returns the most appropriate fileset ID based on the testament of the [book].
  String getBestFilesetId(Book book) {
    String filesetId = abbr;
    final allFilesets = filesets.values.expand((list) => list).toList();

    if (allFilesets.isNotEmpty) {
      final isOT = book.testament == 'OT';
      final isNT = book.testament == 'NT';

      String? bestId;
      for (final fs in allFilesets) {
        final id = fs.id;
        if (id.length >= 6) {
          final portion = id[5]; // O=OT, N=NT, C=Complete, P=Partial
          if ((isOT && (portion == 'O' || portion == 'C')) ||
              (isNT && (portion == 'N' || portion == 'C')) ||
              (!isOT && !isNT)) {
            bestId = id;
            if (id.contains('opus16')) {
              break; // Prefer opus16 formats if available
            }
          }
        }
      }
      filesetId = bestId ?? allFilesets.first.id;
    }
    return filesetId;
  }
}
