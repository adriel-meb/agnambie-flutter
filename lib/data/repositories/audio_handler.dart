import 'package:flutter/foundation.dart';

// =============================================================================
// File: audio_handler.dart
// Purpose: Implements background audio controls and system media notifications using audio_service and just_audio.
// Author: Contributor
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// =============================================================================

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// The AudioHandler connects just_audio to the operating system's background
/// audio API (Control Center on iOS, Media Style notification on Android).
///
/// It extends [BaseAudioHandler] and mixes in [SeekHandler] to enable lock-screen
/// media controls, progress tracking, and playback event synchronization.
class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Creates a new instance of [AppAudioHandler] and sets up listeners
  /// to sync playback state changes with the host operating system.
  AppAudioHandler() {
    // Broadcast state changes to the OS media notification / Control Center
    _player.setVolume(1.0);

    _player.playbackEventStream.listen(_broadcastState);
    
    // Stop playback if we reach the end of the current audio item
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });
  }

  /// Expose the underlying player so the UI can listen directly to streams
  /// (e.g. positionStream, durationStream) for high-refresh-rate UI updates.
  AudioPlayer get player => _player;

  /// Loads a single URL and starts playing it.
  ///
  /// Updates the current [mediaItem] metadata on the lock screen and in the
  /// notification area before configuring the [AudioSource] and starting playback.
  /// Throws if the audio cannot be fetched or parsed.
  Future<void> loadAndPlay(String url, MediaItem mediaItem) async {
    // Publish media metadata to OS notification before audio starts loading
    this.mediaItem.add(mediaItem);
    debugPrint('Loading audio URL: $url');
    try {
      // Set audio URI source for streaming playback
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      play();
    } catch (e) {
      // Broadcast error state if network drops or URI fails to resolve
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }

  /// Starts or resumes audio playback on the underlying [_player].
  @override
  Future<void> play() => _player.play();

  /// Pauses audio playback on the underlying [_player].
  @override
  Future<void> pause() => _player.pause();

  /// Seeks to a specific [position] within the currently playing audio stream.
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Stops playback, clears underlying player resources, and delegates to [BaseAudioHandler.stop].
  @override
  Future<void> stop() async {
    // Stop the underlying audio player
    await _player.stop();
    return super.stop();
  }

  /// Maps just_audio's internal state to audio_service's PlaybackState.
  ///
  /// Broadcasts notification controls, action sets, buffered positions, and
  /// active playback speeds to the underlying OS media manager.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      // Configure interactive buttons shown in the notification / lock screen
      controls: [
        MediaControl.rewind,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
      ],
      // Allow lock screen and car interfaces to scrub or step forward/back
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      // Display rewind, play/pause, and fast forward in Android compact notification view
      androidCompactActionIndices: const [0, 1, 2],
      // Translate just_audio ProcessingState enum to audio_service AudioProcessingState enum
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }
}
