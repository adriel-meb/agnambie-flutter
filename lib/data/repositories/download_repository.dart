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
    String? language,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = url.contains('.m3u8') ? '.m3u8' : '.mp3'; // Fallback for media container extension
    final filePath = '${dir.path}/$bibleId-$bookId-$chapter$ext';
    
    int totalSizeInBytes = 0;

    if (ext == '.m3u8') {
      // Fetch the playlist content
      final response = await _dio.get<String>(url);
      final playlistContent = response.data!;
      final lines = playlistContent.split('\n');
      
      final localPlaylistLines = <String>[];
      int segmentIndex = 0;
      
      // Extract base URL for relative segment paths
      final baseUrl = url.substring(0, url.lastIndexOf('/') + 1);
      
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        
        if (line.startsWith('#')) {
          localPlaylistLines.add(line);
        } else {
          // It's a segment URL
          final segmentUrl = line.startsWith('http') ? line : '$baseUrl$line';
          // Use .mp3 since they are audio segments and it works fine, or extract extension
          final segmentFilename = '$bibleId-$bookId-$chapter-seg$segmentIndex.mp3';
          final segmentPath = '${dir.path}/$segmentFilename';
          
          await _dio.download(segmentUrl, segmentPath);
          final segmentFile = File(segmentPath);
          totalSizeInBytes += await segmentFile.length();
          
          // Add relative path to local playlist
          localPlaylistLines.add(segmentFilename);
          segmentIndex++;
        }
      }
      
      // Save local playlist
      final localPlaylistFile = File(filePath);
      await localPlaylistFile.writeAsString(localPlaylistLines.join('\n'));
      totalSizeInBytes += await localPlaylistFile.length();
      
    } else {
      // Standard single file download
      await _dio.download(url, filePath);
      final file = File(filePath);
      totalSizeInBytes = await file.length();
    }

    final download = Download(
      bibleId: bibleId,
      bookId: bookId,
      chapter: chapter,
      filePath: filePath,
      sizeInBytes: totalSizeInBytes,
      downloadedAt: DateTime.now(),
      bibleVersion: bibleVersion,
      bibleName: bibleName,
      language: language,
    );

    await _localData.saveDownload(download);
  }

  /// Removes an individual chapter's audio file from disk and deletes its database entry.
  Future<void> removeDownload(String bibleId, String bookId, int chapter) async {
    final download = await _localData.getDownload(bibleId, bookId, chapter);
    if (download != null) {
      final file = File(download.filePath);
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        if (download.filePath.endsWith('.m3u8')) {
          // Read the m3u8 to find and delete the segments
          final lines = await file.readAsLines();
          final dirPath = file.parent.path;
          for (final line in lines) {
            if (line.trim().isNotEmpty && !line.startsWith('#')) {
              final segmentFile = File('$dirPath/$line');
              // ignore: avoid_slow_async_io
              if (await segmentFile.exists()) {
                await segmentFile.delete();
              }
            }
          }
        }
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

