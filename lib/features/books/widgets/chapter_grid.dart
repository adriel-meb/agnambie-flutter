// File: chapter_grid.dart
// Purpose: Displays a grid of chapters for a specific book.
// Author: Placeholder
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter/material.dart';

import '../../../data/models/book.dart';

/// A grid widget displaying all chapters of a [book].
class ChapterGrid extends StatelessWidget {
  /// The book containing the chapters to display.
  final Book book;

  /// Callback when a chapter is selected.
  final void Function(int chapter) onChapterSelected;

  /// Creates a [ChapterGrid] for the given [book].
  const ChapterGrid({
    super.key,
    required this.book,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: book.chapters.length,
        itemBuilder: (context, i) {
          final chapter = book.chapters[i] as int;
          return InkWell(
            onTap: () => onChapterSelected(chapter),
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chapter.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: themeData.colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
