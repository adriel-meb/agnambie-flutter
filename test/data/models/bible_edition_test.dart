// -----------------------------------------------------------------------------
// File: bible_edition_test.dart
// Purpose: Unit tests for BibleEdition and FilesetEntry JSON parsing.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/data/models/bible_edition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BibleEdition.fromJson', () {
    test('parses scalar fields and fileset groups keyed by bucket', () {
      final edition = BibleEdition.fromJson({
        'id': 'FANBSG',
        'abbr': 'BSG',
        'name': 'Fang Bible',
        'vname': 'Kalara',
        'language': 'Fang',
        'iso': 'fan',
        'filesets': {
          'dbp-prod': [
            {'id': 'FANBSGN2DA', 'set_type_code': 'audio_drama', 'set_size_code': 'NT'},
            {'id': 'FANBSGN2DA-opus16', 'set_type_code': 'audio_drama', 'set_size_code': 'NT'},
          ],
          'dbp-vid': <dynamic>[],
        },
      });

      expect(edition.id, 'FANBSG');
      expect(edition.abbr, 'BSG');
      expect(edition.name, 'Fang Bible');
      expect(edition.vname, 'Kalara');
      expect(edition.language, 'Fang');
      expect(edition.iso, 'fan');

      expect(edition.filesets.keys, containsAll(['dbp-prod', 'dbp-vid']));
      expect(edition.filesets['dbp-prod'], hasLength(2));
      expect(edition.filesets['dbp-vid'], isEmpty);

      final first = edition.filesets['dbp-prod']!.first;
      expect(first.id, 'FANBSGN2DA');
      expect(first.setTypeCode, 'audio_drama');
      expect(first.setSizeCode, 'NT');
    });

    test('handles missing filesets and fields gracefully', () {
      final edition = BibleEdition.fromJson(const {'id': 'X'});

      expect(edition.id, 'X');
      expect(edition.name, isEmpty);
      expect(edition.filesets, isEmpty);
    });
  });

  group('FilesetEntry.fromJson', () {
    test('defaults missing codes to empty strings', () {
      final entry = FilesetEntry.fromJson(const {'id': 'ABC'});

      expect(entry.id, 'ABC');
      expect(entry.setTypeCode, isEmpty);
      expect(entry.setSizeCode, isEmpty);
    });
  });
}
