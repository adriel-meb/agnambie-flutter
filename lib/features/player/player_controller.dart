// -----------------------------------------------------------------------------
// Purpose: State management and metadata models for audio chapter playback.
// Author: Author Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics_service.dart';
import '../../data/repositories/providers.dart';

/// Metadata model encapsulating details of an active or queued audio track.
class TrackMetadata {
  /// The ISO 639-3 language code of the recording (e.g. 'fra', 'myb').
  final String languageIso;

  /// The Bible identifier or translation code.
  final String bibleId;

  /// The audio fileset identifier used by the backend to fetch audio files.
  final String filesetId;

  /// Standard book abbreviation or identifier (e.g. 'JHN', 'MAT').
  final String bookId;

  /// Optional display name of the book returned by the API or catalog.
  final String? bookName;

  /// The chapter number of the book currently being played.
  final int chapter;

  /// Creates a new [TrackMetadata] instance.
  TrackMetadata({
    required this.languageIso,
    required this.bibleId,
    required this.filesetId,
    required this.bookId,
    this.bookName,
    required this.chapter,
  });
}

// ---------------------------------------------------------------------------
// Player error notifier
// ---------------------------------------------------------------------------

/// Exposes the most recent playback error message, or null when there is none.
///
/// Using a [Notifier] instead of StateProvider (removed in Riverpod 3) to
/// keep consistent with the rest of the project and satisfy strict lints.
/// Separate from [PlayerController] so a transient network error can be shown
/// without clearing the [TrackMetadata] that drives the player UI.
class PlayerErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Sets the error message to display.
  void setError(String message) => state = message;

  /// Clears the current error.
  void clear() => state = null;
}

final playerErrorProvider =
    NotifierProvider<PlayerErrorNotifier, String?>(PlayerErrorNotifier.new);

// ---------------------------------------------------------------------------
// Player controller
// ---------------------------------------------------------------------------

/// Riverpod notifier responsible for managing the active [TrackMetadata]
/// and coordinating audio playback with the underlying repository.
class PlayerController extends Notifier<TrackMetadata?> {
  /// Initializes the controller. Restores state from the active media item if
  /// the app was restarted while a track was playing.
  @override
  TrackMetadata? build() {
    try {
      final handler = ref.read(audioHandlerProvider);
      final item = handler.mediaItem.value;
      if (item != null && item.extras != null) {
        final ext = item.extras!;
        return TrackMetadata(
          languageIso: ext['languageIso'] as String? ?? '',
          bibleId: ext['filesetId'] as String? ?? '',
          filesetId: ext['filesetId'] as String? ?? '',
          bookId: ext['bookId'] as String? ?? '',
          bookName: ext['bookName'] as String?,
          chapter: ext['chapter'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Stops playback completely, clears the track state, and dismisses the mini player.
  Future<void> close() async {
    final repo = ref.read(playerRepositoryProvider);
    await repo.player.stop();
    state = null;
    // Clear any lingering error when the player is explicitly closed
    ref.read(playerErrorProvider.notifier).clear();
  }

  /// Triggers playback for a specific Bible chapter and updates state.
  ///
  /// Updates [state] optimistically so the mini player and player screen appear
  /// immediately. On failure the previous state is restored and [playerErrorProvider]
  /// is set with a user-facing French error message so the UI can surface it.
  Future<void> playChapter({
    required String languageIso,
    required String bibleId,
    required String filesetId,
    required String bookId,
    String? bookName,
    required int chapter,
  }) async {
    final previousState = state;
    // Clear any previous error when starting a new chapter
    ref.read(playerErrorProvider.notifier).clear();

    // 1. Update state immediately for optimistic UI (mini player appears at once)
    state = TrackMetadata(
      languageIso: languageIso,
      bibleId: bibleId,
      filesetId: filesetId,
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
    );

    try {
      // 2. Instruct the repository to fetch the audio URL and begin playback
      final repo = ref.read(playerRepositoryProvider);
      await repo.playChapter(
        languageIso: languageIso,
        // filesetId is passed as bibleId because the API expects the specific
        // audio fileset ID (e.g. "FANBSGN2DA"), not the Bible abbreviation.
        bibleId: filesetId,
        bookId: bookId,
        chapter: chapter,
      );

      // Record offline-batched analytics event
      unawaited(
        ref.read(analyticsServiceProvider).logEvent('chapter_played', {
          'language_iso': languageIso,
          'bible_id': bibleId,
          'fileset_id': filesetId,
          'book_id': bookId,
          'chapter': chapter,
        }),
      );
    } catch (e) {
      // Revert state so the UI does not show a track that never loaded
      state = previousState;
      // Surface a friendly error — do not rethrow, UI handles it via provider
      ref.read(playerErrorProvider.notifier).setError(
        'Impossible de lire ce chapitre. Vérifiez votre connexion et réessayez.',
      );
    }
  }
}

/// Global provider for [PlayerController], providing access to the current [TrackMetadata].
final playerControllerProvider =
    NotifierProvider<PlayerController, TrackMetadata?>(() {
      return PlayerController();
    });
