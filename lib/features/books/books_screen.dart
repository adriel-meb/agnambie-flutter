// File: books_screen.dart
// Purpose: Displays the list of books for a selected Bible edition and allows chapter selection and playback.
// Author: Adriel
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/gabon.dart';
import '../../data/models/bible_edition.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/skeleton.dart';
import '../player/mini_player.dart';
import 'books_providers.dart';
import 'widgets/bible_header.dart';
import 'widgets/book_row.dart';

/// A screen that displays all available books for a selected [BibleEdition].
///
/// Users can browse books, expand multi-chapter books into a chapter grid,
/// and trigger audio playback for a chosen chapter.
class BooksScreen extends ConsumerWidget {
  /// The Bible edition whose books and chapters are displayed.
  final BibleEdition bible;

  /// Creates a [BooksScreen] for the given [bible] edition.
  const BooksScreen({super.key, required this.bible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch books using the bible's language ISO and ID
    // Note: The backend 'books' endpoint requires a bible_id.
    // If the backend expects a fileset ID, we might need to map it,
    // but the backend handler specifically says "bible_id".
    final request = BooksRequest(
      languageIso: bible.language,
      bibleId: bible.abbr,
    );
    final booksAsyncValue = ref.watch(booksProvider(request));

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: AppBar(
        title: const Text(Constants.APP_TITLE),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              BibleHeader(bible: bible),
              const SizedBox(height: 24),

              // Books list view with async state handling
              Expanded(
                child: booksAsyncValue.when(
                  loading: () => ListView.separated(
                    itemCount: 8,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => const SkeletonLoader(height: 60),
                  ),

                  error: (err, stack) => AppErrorView(
                    message: 'Impossible de charger les livres.',
                    onRetry: () => ref.invalidate(booksProvider(request)),
                  ),
                  data: (books) {
                    if (books.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun livre trouvé.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: books.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookRow(bible: bible, book: book);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
