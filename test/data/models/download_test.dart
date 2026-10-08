// -----------------------------------------------------------------------------
// File: download_test.dart
// Purpose: Unit tests for the Download local record model.
// Author: Agnambie Team
// Creation Date: 2026-10-08
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:agnambie/data/models/download.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final original = Download(
    bibleId: 'FANBSGN2DA',
    bookId: 'MAT',
    chapter: 1,
    filePath: '/docs/FANBSGN2DA_MAT_1.mp3',
    sizeInBytes: 426956,
    downloadedAt: DateTime.utc(2026, 10, 8),
    bibleVersion: 'BSG',
    bibleName: 'Fang Bible',
    language: 'Fang',
  );

  group('Download.copyWith', () {
    test('returns an identical record when no arguments are given', () {
      final copy = original.copyWith();

      expect(copy.bibleId, original.bibleId);
      expect(copy.bookId, original.bookId);
      expect(copy.chapter, original.chapter);
      expect(copy.filePath, original.filePath);
      expect(copy.sizeInBytes, original.sizeInBytes);
      expect(copy.downloadedAt, original.downloadedAt);
      expect(copy.bibleVersion, original.bibleVersion);
      expect(copy.bibleName, original.bibleName);
      expect(copy.language, original.language);
    });

    test('overrides only the provided fields', () {
      final copy = original.copyWith(chapter: 2, sizeInBytes: 1000);

      expect(copy.chapter, 2);
      expect(copy.sizeInBytes, 1000);
      expect(copy.bibleId, original.bibleId);
      expect(copy.filePath, original.filePath);
    });
  });

  test('optional metadata defaults to null', () {
    final minimal = Download(
      bibleId: 'X',
      bookId: 'GEN',
      chapter: 1,
      filePath: '/f.mp3',
      sizeInBytes: 0,
      downloadedAt: DateTime.utc(2026),
    );

    expect(minimal.bibleVersion, isNull);
    expect(minimal.bibleName, isNull);
    expect(minimal.language, isNull);
  });
}
