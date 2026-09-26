// -----------------------------------------------------------------------------
// File: download_repository.dart
// Purpose: Repository orchestrating downloading, local storage, and removal of audio chapters.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download.dart';
import '../datasources/downloads_local.dart';

/// Repository managing audio chapter file downloads and local metadata persistence.
class DownloadRepository {
  final DownloadsLocalDataSource _localData;
  final Dio _dio;

  /// Creates a [DownloadRepository] with local data source and HTTP client.
  DownloadRepository(this._localData, this._dio);

  /// Retrieves all downloaded chapters from local storage.
  Future<List<Download>> getAllDownloads() async {
    return await _localData.getAllDownloads();
  }
  
  /// Retrieves a specific chapter download if present.
  Future<Download?> getDownload(String bibleId, String bookId, int chapter) async {
    return await _localData.getDownload(bibleId, bookId, chapter);
  }

  /// Downloads the file from the given [url] and saves it with edition metadata.
  Future<void> downloadChapter(
    String url,
    String bibleId,
    String bookId,
    int chapter, {
    String? bibleVersion,
    String? bibleName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = url.contains('.m3u8') ? '.m3u8' : '.mp3'; // Fallback for media container extension
    
    // Note: HLS m3u8 streams cannot be downloaded simply via single file get. 
    // This implementation works for MP3/WebM CDN files.
    final filePath = '${dir.path}/$bibleId-$bookId-$chapter$ext';

    // Download the file stream to disk
    await _dio.download(url, filePath);
    
    final file = File(filePath);
    final sizeInBytes = await file.length();

    final download = Download(
      bibleId: bibleId,
      bookId: bookId,
      chapter: chapter,
      filePath: filePath,
      sizeInBytes: sizeInBytes,
      downloadedAt: DateTime.now(),
      bibleVersion: bibleVersion,
      bibleName: bibleName,
    );

    await _localData.saveDownload(download);
  }

  /// Removes an individual chapter's audio file from disk and deletes its database entry.
  Future<void> removeDownload(String bibleId, String bookId, int chapter) async {
    final download = await _localData.getDownload(bibleId, bookId, chapter);
    if (download != null) {
      final file = File(download.filePath);
      // ignore: avoid_slow_async_io — no safe sync alternative for file.exists() cross-platform
      if (await file.exists()) {
        await file.delete();
      }
      await _localData.deleteDownload(bibleId, bookId, chapter);
    }
  }

  /// Removes all downloaded chapters belonging to a specific book and Bible edition.
  Future<void> removeBookDownloads(String bibleId, String bookId) async {
    final all = await _localData.getAllDownloads();
    final matching = all.where((d) => d.bibleId == bibleId && d.bookId == bookId).toList();
    for (final item in matching) {
      await removeDownload(item.bibleId, item.bookId, item.chapter);
    }
  }

  /// Calculates the total storage used by all offline audio chapters in bytes.
  Future<int> getTotalStorageUsed() async {
    final downloads = await _localData.getAllDownloads();
    return downloads.fold<int>(0, (sum, item) => sum + item.sizeInBytes);
  }
}

