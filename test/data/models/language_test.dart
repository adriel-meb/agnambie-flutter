// -----------------------------------------------------------------------------
// File: language_test.dart
// Purpose: Unit tests for Language and Fileset JSON parsing.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/data/models/language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Language.fromJson', () {
    test('parses all fields including nested filesets', () {
      final language = Language.fromJson({
        'code': 'FAN',
        'name': 'Fang',
        'native_name': 'Fang',
        'filesets': [
          {
            'id': 'FANBSGN2DA',
            'data_saver_id': 'FANBSGN2DA-opus16',
            'type': 'audio_drama',
            'codec': 'mp3',
            'description': 'Fang - Bible Society of Gabon',
            'size': 'NT',
          },
        ],
      });

      expect(language.code, 'FAN');
      expect(language.name, 'Fang');
      expect(language.nativeName, 'Fang');
      expect(language.filesets, hasLength(1));

      final fileset = language.filesets.single;
      expect(fileset.id, 'FANBSGN2DA');
      expect(fileset.dataSaverId, 'FANBSGN2DA-opus16');
      expect(fileset.type, 'audio_drama');
      expect(fileset.codec, 'mp3');
      expect(fileset.description, 'Fang - Bible Society of Gabon');
      expect(fileset.size, 'NT');
    });

    test('defaults missing fields to empty values instead of throwing', () {
      final language = Language.fromJson(const {});

      expect(language.code, isEmpty);
      expect(language.name, isEmpty);
      expect(language.nativeName, isEmpty);
      expect(language.filesets, isEmpty);
    });

    test('treats explicit nulls like missing fields', () {
      final language = Language.fromJson(const {
        'code': null,
        'native_name': null,
        'filesets': null,
      });

      expect(language.code, isEmpty);
      expect(language.nativeName, isEmpty);
      expect(language.filesets, isEmpty);
    });
  });

  group('Fileset.fromJson', () {
    test('defaults an absent data_saver_id to empty string', () {
      final fileset = Fileset.fromJson(const {'id': 'FRNLSNN1DA'});

      expect(fileset.id, 'FRNLSNN1DA');
      expect(fileset.dataSaverId, isEmpty);
    });
  });
}
