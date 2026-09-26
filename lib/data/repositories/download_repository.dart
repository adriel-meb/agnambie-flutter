import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download.dart';
import '../datasources/downloads_local.dart';

class DownloadRepository {
  final DownloadsLocalDataSource _localData;
  final Dio _dio;

  DownloadRepository(this._localData, this._dio);

  Future<List<Download>> getAllDownloads() async {
    return await _localData.getAllDownloads();
  }
  
  Future<Download?> getDownload(String bibleId, String bookId, int chapter) async {
    return await _localData.getDownload(bibleId, bookId, chapter);
  }

  /// Downloads the file from the given URL and saves it to local storage.
  Future<void> downloadChapter(String url, String bibleId, String bookId, int chapter) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = url.contains('.m3u8') ? '.m3u8' : '.mp3'; // Simplistic fallback
    
    // Note: HLS m3u8 streams cannot be downloaded simply via single file get. 
    // This implementation works for MP3/WebM CDN files.
    final filePath = '${dir.path}/$bibleId-$bookId-$chapter$ext';

    // Download the file
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
    );

    await _localData.saveDownload(download);
  }

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

  Future<int> getTotalStorageUsed() async {
    final downloads = await _localData.getAllDownloads();
    return downloads.fold<int>(0, (sum, item) => sum + item.sizeInBytes);
  }
}
