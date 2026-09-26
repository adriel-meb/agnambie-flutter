// -----------------------------------------------------------------------------
// File: book_row.dart
// Purpose: Displays an expandable row for a book with chapters.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/book_names.dart';
import '../../../data/models/bible_edition.dart';
import '../../../data/models/book.dart';
import '../../player/player_controller.dart';
import '../../player/player_screen.dart';
import '../download_sheet.dart';
import '../utils/fileset_utils.dart';
import 'chapter_grid.dart';

/// An expandable row widget representing a single [Book].
///
/// Tapping the row toggles a chapter grid if the book contains multiple chapters,
/// or directly initiates playback if it only has a single chapter.
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final hasMultipleChapters = widget.book.chapters.length > 1;

    return Consumer(
      builder: (context, ref, child) {
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
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      onPressed: () {
                        showDownloadSheet(
                            context,
                            widget.bible,
                            widget.book,
                            widget.bible.getBestFilesetId(widget.book));
                      },
                      icon: const Icon(Icons.download_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: themeData.colorScheme.primary
                            .withValues(alpha: 0.1),
                        foregroundColor: themeData.colorScheme.primary,
                      ),
                    ),
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
