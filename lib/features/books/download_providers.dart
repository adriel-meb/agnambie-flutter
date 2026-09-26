// -----------------------------------------------------------------------------
// File: download_providers.dart
// Purpose: State management and progress tracking for audio book downloads.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the active download state and progress of an individual Bible book.
@immutable
class BookDownloadState {
  /// The index of the chapter currently being downloaded or completed.
  final int completedChapters;

  /// The total number of chapters in the target book.
  final int totalChapters;

  /// Whether an active download process is currently running for this book.
  final bool isDownloading;

  /// An optional user-facing error message describing a failed download step.
  final String? errorMessage;

  /// Creates an immutable [BookDownloadState] instance.
  const BookDownloadState({
    required this.completedChapters,
    required this.totalChapters,
    required this.isDownloading,
    this.errorMessage,
  });

  /// Computes the normalized download progression fraction between 0.0 and 1.0.
  double get progress =>
      totalChapters > 0 ? (completedChapters / totalChapters).clamp(0.0, 1.0) : 0.0;

  /// Creates a copy of this state with specified fields replaced.
  BookDownloadState copyWith({
    int? completedChapters,
    int? totalChapters,
    bool? isDownloading,
    String? errorMessage,
  }) {
    return BookDownloadState(
      completedChapters: completedChapters ?? this.completedChapters,
      totalChapters: totalChapters ?? this.totalChapters,
      isDownloading: isDownloading ?? this.isDownloading,
      errorMessage: errorMessage,
    );
  }
}

/// Key generator for indexing download operations by unique fileset and book IDs.
String bookDownloadKey(String filesetId, String bookId) => '${filesetId}_$bookId';

/// Notifier tracking active download progress keyed by [bookDownloadKey].
class BookDownloadNotifier extends Notifier<Map<String, BookDownloadState>> {
  @override
  Map<String, BookDownloadState> build() => const <String, BookDownloadState>{};

  /// Initializes a download task for the given [key] with [totalChapters].
  void startDownload(String key, int totalChapters) {
    state = <String, BookDownloadState>{
      ...state,
      key: BookDownloadState(
        completedChapters: 0,
        totalChapters: totalChapters,
        isDownloading: true,
        errorMessage: null,
      ),
    };
  }

  /// Increments the completed chapters count for [key].
  void updateProgress(String key, int completed) {
    final current = state[key];
    if (current != null) {
      state = <String, BookDownloadState>{
        ...state,
        key: current.copyWith(completedChapters: completed),
      };
    }
  }

  /// Marks the download as completed.
  void finishDownload(String key) {
    final current = state[key];
    if (current != null) {
      state = <String, BookDownloadState>{
        ...state,
        key: current.copyWith(
          isDownloading: false,
          completedChapters: current.totalChapters,
        ),
      };
    }
  }

  /// Records an error message for [key] and terminates the active downloading state.
  void setError(String key, String message) {
    final current = state[key];
    if (current != null) {
      state = <String, BookDownloadState>{
        ...state,
        key: current.copyWith(
          isDownloading: false,
          errorMessage: message,
        ),
      };
    }
  }

  /// Clears any cached download state for [key].
  void clearState(String key) {
    final next = Map<String, BookDownloadState>.from(state);
    next.remove(key);
    state = next;
  }
}

/// Provider managing active download states across all books.
final bookDownloadProgressProvider =
    NotifierProvider<BookDownloadNotifier, Map<String, BookDownloadState>>(
  BookDownloadNotifier.new,
);
