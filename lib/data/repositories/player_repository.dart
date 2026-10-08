// ignore_for_file: prefer_initializing_formals

// =============================================================================
// File: player_repository.dart
// Purpose: Manages audio playback coordination, metadata synchronization, and media service control.
// Author: Contributor
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// =============================================================================

import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/utils/book_names.dart';
import 'catalog_repository.dart';
import 'download_repository.dart';
import 'audio_handler.dart';

/// Abstracts audio playback logic so the UI doesn't need to know 
/// if the audio is streaming from the network or playing locally.
///
/// Coordinates between [CatalogRepository] to obtain streaming audio URLs and
/// [AppAudioHandler] to manage background playback and OS media controls.
class PlayerRepository {
  final CatalogRepository _catalogRepository;
  final DownloadRepository _downloadRepository;
  final AppAudioHandler _audioHandler;

  /// Creates a [PlayerRepository] with dependencies on [CatalogRepository]
  /// and [AppAudioHandler].
  PlayerRepository({
    required CatalogRepository catalogRepository,
    required DownloadRepository downloadRepository,
    required AppAudioHandler audioHandler,
  })  : _catalogRepository = catalogRepository,
        _downloadRepository = downloadRepository,
        _audioHandler = audioHandler;

  /// Exposes the underlying just_audio player so the UI can listen to streams
  /// (playing state, position, duration, etc).
  AudioPlayer get player => _audioHandler.player;

  /// Fetches the correct URL for the chapter and begins playback.
  ///
  /// Resolves the chapter stream URL via [_catalogRepository], builds
  /// localized metadata for the operating system notification area and lock screen,
  /// and commands [_audioHandler] to load and stream the audio.
  ///
  /// Parameters:
  /// - [languageIso]: ISO language code (e.g., 'fan' for Fang, 'fra' for French).
  /// - [bibleId]: Identifier or fileset for the target Bible translation.
  /// - [bookId]: USFM book code (e.g., 'GEN', 'MAT').
  /// - [chapter]: Chapter index number to stream.
  Future<void> playChapter({
    required String languageIso,
    required String bibleId,
    required String bookId,
    required int chapter,
  }) async {
    try {
      final download = await _downloadRepository.getDownload(bibleId, bookId, chapter);
      
      // Resolve human-readable or localized book name
      final bookNameDisplay = BookNames.getBestName(bookId);

      // Pass the metadata to the OS (Lock screen / Control Center / notification drawer)
      var mediaItem = MediaItem(
        id: download != null ? 'file://${download.filePath}' : 'network', // Will be updated for network
        album: '$languageIso · $bibleId',
        title: '$bookNameDisplay · Chapitre $chapter',
        artUri: Uri.parse('https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80'), // Placeholder artwork
        extras: {
          'languageIso': languageIso,
          'filesetId': bibleId,
          'bookId': bookId,
          'bookName': bookNameDisplay,
          'chapter': chapter,
        },
      );

      AudioSource audioSource;
      if (download != null) {
        if (download.filePath.endsWith('.m3u8')) {
          final playlistFile = File(download.filePath);
          final lines = await playlistFile.readAsLines();
          final dirPath = playlistFile.parent.path;
          final sources = <AudioSource>[];
          
          for (final line in lines) {
            if (line.isNotEmpty && !line.startsWith('#')) {
              // line is the segment filename
              final segmentPath = '$dirPath/$line';
              sources.add(AudioSource.uri(Uri.file(segmentPath), tag: mediaItem));
            }
          }
          // ignore: deprecated_member_use
          audioSource = ConcatenatingAudioSource(children: sources);
        } else {
          audioSource = AudioSource.uri(Uri.file(download.filePath), tag: mediaItem);
        }
      } else {
        final url = await _catalogRepository.getChapterAudioUrl(
          languageIso,
          bibleId,
          bookId,
          chapter,
        );
        mediaItem = mediaItem.copyWith(id: url); // Update ID with actual network URL
        audioSource = AudioSource.uri(Uri.parse(url), tag: mediaItem);
      }

      // Load the audio source and play
      await _audioHandler.loadAndPlay(audioSource, mediaItem);
      
    } catch (e) {
      // If the backend returns 404 or network drops, bubble up to UI
      rethrow;
    }
  }

  /// Pauses active audio playback.
  void pause() => _audioHandler.pause();
  
  /// Resumes audio playback from current position.
  void resume() => _audioHandler.play();

  /// Stops audio playback and releases resources held by [_audioHandler].
  void dispose() {
    // Halt playback and clean up audio service
    _audioHandler.stop();
  }
}
