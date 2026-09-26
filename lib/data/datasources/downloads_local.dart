// -----------------------------------------------------------------------------
// File: downloads_local.dart
// Purpose: Local persistence data source for downloaded audio chapters using Hive.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:hive/hive.dart';
import '../models/download.dart';

/// Abstract contract for local download metadata persistence.
abstract class DownloadsLocalDataSource {
  /// Persists a new or updated [download] record to local storage.
  Future<void> saveDownload(Download download);

  /// Retrieves all persisted [Download] records from local storage.
  Future<List<Download>> getAllDownloads();

  /// Deletes a specific download entry identifying [bibleId], [bookId], and [chapter].
  Future<void> deleteDownload(String bibleId, String bookId, int chapter);

  /// Retrieves a specific [Download] entry, or null if not locally cached.
  Future<Download?> getDownload(String bibleId, String bookId, int chapter);
}

/// Concrete implementation of [DownloadsLocalDataSource] backed by Hive.
class HiveDownloadsLocalDataSource implements DownloadsLocalDataSource {
  static const String _boxName = 'downloads';
  
  /// Generates a composite unique key for indexing downloads in the Hive box.
  String _generateKey(String bibleId, String bookId, int chapter) {
    return '${bibleId}_${bookId}_$chapter';
  }

  /// Opens or retrieves the active Hive box safely without rigid map type constraints.
  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return await Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<void> saveDownload(Download download) async {
    final box = await _openBox();
    final key = _generateKey(download.bibleId, download.bookId, download.chapter);
    await box.put(key, <String, dynamic>{
      'bibleId': download.bibleId,
      'bookId': download.bookId,
      'chapter': download.chapter,
      'filePath': download.filePath,
      'sizeInBytes': download.sizeInBytes,
      'downloadedAt': download.downloadedAt.toIso8601String(),
    });
  }

  @override
  Future<List<Download>> getAllDownloads() async {
    final box = await _openBox();
    final results = <Download>[];
    for (final dynamic raw in box.values) {
      if (raw is Map) {
        // Coerce dynamic map to string-keyed map to avoid Hive deserialization cast errors
        final rawItem = Map<String, dynamic>.from(raw);
        results.add(Download(
          bibleId: rawItem['bibleId'] as String? ?? '',
          bookId: rawItem['bookId'] as String? ?? '',
          chapter: (rawItem['chapter'] as num?)?.toInt() ?? 1,
          filePath: rawItem['filePath'] as String? ?? '',
          sizeInBytes: (rawItem['sizeInBytes'] as num?)?.toInt() ?? 0,
          downloadedAt: rawItem['downloadedAt'] != null
              ? DateTime.tryParse(rawItem['downloadedAt'] as String) ?? DateTime.now()
              : DateTime.now(),
        ));
      }
    }
    return results;
  }

  @override
  Future<void> deleteDownload(String bibleId, String bookId, int chapter) async {
    final box = await _openBox();
    final key = _generateKey(bibleId, bookId, chapter);
    await box.delete(key);
  }

  @override
  Future<Download?> getDownload(String bibleId, String bookId, int chapter) async {
    final box = await _openBox();
    final key = _generateKey(bibleId, bookId, chapter);
    final dynamic raw = box.get(key);
    if (raw == null || raw is! Map) return null;
    
    final rawItem = Map<String, dynamic>.from(raw);
    return Download(
      bibleId: rawItem['bibleId'] as String? ?? '',
      bookId: rawItem['bookId'] as String? ?? '',
      chapter: (rawItem['chapter'] as num?)?.toInt() ?? 1,
      filePath: rawItem['filePath'] as String? ?? '',
      sizeInBytes: (rawItem['sizeInBytes'] as num?)?.toInt() ?? 0,
      downloadedAt: rawItem['downloadedAt'] != null
          ? DateTime.tryParse(rawItem['downloadedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
