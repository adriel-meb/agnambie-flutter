import 'package:hive/hive.dart';
import '../models/download.dart';

abstract class DownloadsLocalDataSource {
  Future<void> saveDownload(Download download);
  Future<List<Download>> getAllDownloads();
  Future<void> deleteDownload(String bibleId, String bookId, int chapter);
  Future<Download?> getDownload(String bibleId, String bookId, int chapter);
}

class HiveDownloadsLocalDataSource implements DownloadsLocalDataSource {
  static const String _boxName = 'downloads';
  
  String _generateKey(String bibleId, String bookId, int chapter) {
    return '${bibleId}_${bookId}_$chapter';
  }

  @override
  Future<void> saveDownload(Download download) async {
    final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
    final key = _generateKey(download.bibleId, download.bookId, download.chapter);
    await box.put(key, {
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
    final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
    final results = <Download>[];
    for (final rawItem in box.values) {
      results.add(Download(
        bibleId: rawItem['bibleId'] as String,
        bookId: rawItem['bookId'] as String,
        chapter: rawItem['chapter'] as int,
        filePath: rawItem['filePath'] as String,
        sizeInBytes: rawItem['sizeInBytes'] as int,
        downloadedAt: DateTime.parse(rawItem['downloadedAt'] as String),
      ));
    }
    return results;
  }

  @override
  Future<void> deleteDownload(String bibleId, String bookId, int chapter) async {
    final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
    final key = _generateKey(bibleId, bookId, chapter);
    await box.delete(key);
  }

  @override
  Future<Download?> getDownload(String bibleId, String bookId, int chapter) async {
    final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
    final key = _generateKey(bibleId, bookId, chapter);
    final rawItem = box.get(key);
    if (rawItem == null) return null;
    return Download(
      bibleId: rawItem['bibleId'] as String,
      bookId: rawItem['bookId'] as String,
      chapter: rawItem['chapter'] as int,
      filePath: rawItem['filePath'] as String,
      sizeInBytes: rawItem['sizeInBytes'] as int,
      downloadedAt: DateTime.parse(rawItem['downloadedAt'] as String),
    );
  }
}
