// -----------------------------------------------------------------------------
// File: book_test.dart
// Purpose: Unit tests for Book JSON parsing.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/data/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book.fromJson', () {
    test('parses identifiers, testament and chapter list', () {
      final book = Book.fromJson({
        'book_id': 'MAT',
        'book_id_usfx': 'MT',
        'book_id_osis': 'Matt',
        'name': 'Matthieu',
        'testament': 'NT',
        'book_group': 'Gospels',
        'chapters': [1, 2, 3],
      });

      expect(book.bookId, 'MAT');
      expect(book.bookIdUsfx, 'MT');
      expect(book.bookIdOsis, 'Matt');
      expect(book.name, 'Matthieu');
      expect(book.testament, 'NT');
      expect(book.bookGroup, 'Gospels');
      expect(book.chapters, [1, 2, 3]);
    });

    test('defaults missing fields and chapters to empty values', () {
      final book = Book.fromJson(const {'book_id': 'GEN'});

      expect(book.bookId, 'GEN');
      expect(book.name, isEmpty);
      expect(book.testament, isEmpty);
      expect(book.chapters, isEmpty);
    });
  });
}
