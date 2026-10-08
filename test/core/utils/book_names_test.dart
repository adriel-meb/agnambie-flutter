// -----------------------------------------------------------------------------
// File: book_names_test.dart
// Purpose: Unit tests for BookNames.getBestName display-name selection.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/core/utils/book_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookNames.getBestName', () {
    test('prefers a localised API name (e.g. Fang) over the French fallback', () {
      expect(BookNames.getBestName('MAT', apiName: 'Matayo'), 'Matayo');
    });

    test('replaces an English API name with the French name', () {
      expect(BookNames.getBestName('MAT', apiName: 'Matthew'), 'Matthieu');
    });

    test('replaces an API name that is just the book ID', () {
      expect(BookNames.getBestName('GEN', apiName: 'GEN'), 'Genèse');
    });

    test('uses the French name when no API name is given', () {
      expect(BookNames.getBestName('REV'), 'Apocalypse');
      expect(BookNames.getBestName('REV', apiName: ''), 'Apocalypse');
    });

    test('falls back to the English API name for unknown book IDs', () {
      expect(BookNames.getBestName('XYZ', apiName: 'Matthew'), 'Matthew');
    });

    test('falls back to the raw book ID when nothing else is available', () {
      expect(BookNames.getBestName('XYZ'), 'XYZ');
    });

    test('has a French name for all 66 canonical books', () {
      expect(BookNames.frenchNames, hasLength(66));
    });
  });
}
