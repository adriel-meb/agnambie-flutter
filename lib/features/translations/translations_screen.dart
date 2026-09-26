// File: translations_screen.dart
// Purpose: Displays available Bible translations/editions for a selected language.
// Author: Adriel
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/gabon.dart';
import '../../data/models/language.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/bible_row.dart';
import '../../widgets/skeleton.dart';

import '../books/books_screen.dart';
import '../player/mini_player.dart';
import 'translations_providers.dart';

/// A screen displaying all available Bible editions/translations for a specific [Language].
///
/// Users can select a translation to navigate to its books list via [BooksScreen].
class TranslationsScreen extends ConsumerWidget {
  /// The selected language whose translations are shown.
  final Language language;

  /// Creates a [TranslationsScreen] for the specified [language].
  const TranslationsScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    
    // Watch the future provider for this specific language's bibles
    final biblesAsyncValue = ref.watch(biblesProvider(language.code));

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: AppBar(
        title: const Text(
          Constants.APP_TITLE,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Country flag and name header
              Text(
                '${Constants.COUNTRY_FLAG} ${Constants.COUNTRY_NAME}',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: themeData.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Language title
              Text(
                language.name,
                style: themeData.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              // Instructional subtitle
              const Text(
                'Choisissez une traduction audio.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Bible editions list view with async state handling
              Expanded(
                child: biblesAsyncValue.when(
                  loading: () => ListView.separated(
                    itemCount: 6,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => const SkeletonLoader(height: 100),
                  ),
                  error: (err, stack) => AppErrorView(
                    message: 'Impossible de charger les traductions.',
                    onRetry: () => ref.invalidate(biblesProvider(language.code)),
                  ),
                  data: (bibles) {
                    if (bibles.isEmpty) {
                      return const Center(
                        child: Text('Aucune Bible ne correspond à votre recherche.', style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return ListView.separated(
                      itemCount: bibles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bible = bibles[index];
                        return BibleRow(
                          bible: bible,
                          onTap: () {
                            // Navigate to the books screen for the chosen Bible edition
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => BooksScreen(bible: bible),
                              ),
                            );
                          },
                        );
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
