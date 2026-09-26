// -----------------------------------------------------------------------------
// File: book_row.dart
// Purpose: Displays an expandable row for a book with chapters, download progress,
//          and offline status indicators.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/book_names.dart';
import '../../../data/models/bible_edition.dart';
import '../../../data/models/book.dart';
import '../../../data/repositories/providers.dart';
import '../../offline/offline_providers.dart';
import '../../player/player_controller.dart';
import '../../player/player_screen.dart';
import '../download_providers.dart';
import '../download_sheet.dart';
import '../utils/fileset_utils.dart';
import 'chapter_grid.dart';

/// An expandable row widget representing a single [Book].
///
/// Tapping the row toggles a chapter grid if the book contains multiple chapters,
/// or directly initiates playback if it only has a single chapter. The trailing action
/// reflects active download progress, completed offline status, or download sheet access.
class BookRow extends StatefulWidget {
  /// The parent Bible edition.
  final BibleEdition bible;

  /// The book represented by this row.
  final Book book;

  /// Creates a [BookRow] with the associated [bible] and [book].
  const BookRow({super.key, required this.bible, required this.book});

  @override
  State<BookRow> createState() => _BookRowState();
}

class _BookRowState extends State<BookRow> {
  /// Controls the expansion state of the chapters grid for multi-chapter books.
  bool _isExpanded = false;

  /// Starts playback for the given [chapter] and opens the fullscreen player.
  ///
  /// Errors during playback are surfaced through [playerErrorProvider] and
  /// displayed by [PlayerScreen] as a SnackBar — no try/catch needed here.
  void _playChapter(BuildContext context, WidgetRef ref, int chapter) {
    final filesetId = widget.bible.getBestFilesetId(widget.book);

    // Fire-and-forget — PlayerController handles errors via playerErrorProvider
    ref.read(playerControllerProvider.notifier).playChapter(
      languageIso: widget.bible.language,
      bibleId: widget.bible.abbr,
      filesetId: filesetId,
      bookId: widget.book.bookId,
      bookName: widget.book.name,
      chapter: chapter,
    );

    // Present the player screen modally
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PlayerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  /// Displays an options sheet for an already downloaded book, allowing deletion.
  void _showDownloadedBookOptions(
    BuildContext context,
    WidgetRef ref,
    String filesetId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.emerald,
                    size: 28,
                  ),
                  title: Text(
                    BookNames.getBestName(
                      widget.book.bookId,
                      apiName: widget.book.name,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Ce livre est disponible hors-connexion (${widget.book.chapters.length} chapitres).',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Supprimer le téléchargement',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final downloader = ref.read(downloadRepositoryProvider);
                    for (final rawChapter in widget.book.chapters) {
                      final chapter = rawChapter as int;
                      await downloader.removeDownload(
                        filesetId,
                        widget.book.bookId,
                        chapter,
                      );
                    }
                    ref.read(bookDownloadProgressProvider.notifier).clearState(
                          bookDownloadKey(filesetId, widget.book.bookId),
                        );
                    ref.invalidate(offlineDownloadsProvider);
                    ref.invalidate(totalStorageUsedProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Téléchargement de ${widget.book.name} supprimé.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the trailing action reflecting download progress, completed state, or download trigger.
  Widget _buildTrailingAction(
    BuildContext context,
    WidgetRef ref,
    ThemeData themeData,
    String filesetId,
    bool isDownloading,
    double progress,
    bool isFullyDownloaded,
  ) {
    if (isDownloading) {
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 3,
                color: themeData.colorScheme.primary,
                backgroundColor:
                    themeData.colorScheme.primary.withValues(alpha: 0.2),
              ),
              if (progress > 0)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: themeData.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (isFullyDownloaded) {
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: IconButton(
          tooltip: 'Livre téléchargé (options)',
          onPressed: () => _showDownloadedBookOptions(context, ref, filesetId),
          icon: const Icon(Icons.check_circle_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
            foregroundColor: AppColors.emerald,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        tooltip: 'Télécharger',
        onPressed: () {
          showDownloadSheet(
            context,
            widget.bible,
            widget.book,
            filesetId,
          );
        },
        icon: const Icon(Icons.download_rounded, size: 20),
        style: IconButton.styleFrom(
          backgroundColor:
              themeData.colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: themeData.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final hasMultipleChapters = widget.book.chapters.length > 1;
    final filesetId = widget.bible.getBestFilesetId(widget.book);
    final downloadKey = bookDownloadKey(filesetId, widget.book.bookId);

    return Consumer(
      builder: (context, ref, child) {
        final downloadProgressMap = ref.watch(bookDownloadProgressProvider);
        final downloadState = downloadProgressMap[downloadKey];
        final isDownloading = downloadState?.isDownloading ?? false;
        final progress = downloadState?.progress ?? 0.0;

        final downloadsAsync = ref.watch(offlineDownloadsProvider);
        final downloadedCount = downloadsAsync.value
                ?.where((d) =>
                    d.bibleId == filesetId && d.bookId == widget.book.bookId)
                .length ??
            0;
        final isFullyDownloaded =
            downloadedCount >= widget.book.chapters.length &&
                widget.book.chapters.isNotEmpty;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      onTap: () {
                        if (hasMultipleChapters) {
                          // Toggle chapter grid visibility for multi-chapter books
                          setState(() => _isExpanded = !_isExpanded);
                        } else {
                          // Play whole book (or chapter 1) directly for single-chapter books
                          final chapter = widget.book.chapters.isNotEmpty
                              ? widget.book.chapters.first as int
                              : 1;
                          _playChapter(context, ref, chapter);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                BookNames.getBestName(
                                  widget.book.bookId,
                                  apiName: widget.book.name,
                                ),
                                style: themeData.textTheme.titleMedium,
                              ),
                            ),
                            if (hasMultipleChapters)
                              Icon(
                                _isExpanded
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: themeData.colorScheme.onSurfaceVariant,
                              )
                            else
                              const Icon(Icons.play_arrow_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildTrailingAction(
                    context,
                    ref,
                    themeData,
                    filesetId,
                    isDownloading,
                    progress,
                    isFullyDownloaded,
                  ),
                ],
              ),

              // Expanded Chapters Grid
              if (_isExpanded && hasMultipleChapters)
                ChapterGrid(
                  book: widget.book,
                  onChapterSelected: (chapter) =>
                      _playChapter(context, ref, chapter),
                ),
            ],
          ),
        );
      },
    );
  }
}
