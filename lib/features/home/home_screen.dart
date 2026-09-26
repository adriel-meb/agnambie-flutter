// -----------------------------------------------------------------------------
// File: home_screen.dart
// Purpose: Main home screen displaying hero header, search bar, spotlight banner, and language list.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/gabon.dart';
import 'spotlight.dart';
import 'language_card.dart';
import 'home_providers.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/skeleton.dart';


/// The main landing/home screen of the Agnambie application.
///
/// Presents Gabon audio Bible overview, search functionality, featured spotlight,
/// and the asynchronous catalog list of available languages.
class HomeScreen extends ConsumerWidget {
  /// Creates a [HomeScreen] instance.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    
    // Watch the future provider for languages to reactively update the UI on state changes.
    final languagesAsyncValue = ref.watch(languagesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header branding and hero titles.
              Text(
                Constants.APP_SUBTITLE,
                style: themeData.textTheme.labelSmall?.copyWith(
                  color: themeData.colorScheme.primary,
                ),
              ),
              Text(
                Constants.HERO_TITLE,
                style: themeData.textTheme.displayLarge,
              ),
              const SizedBox(height: 3),
              Text(
                Constants.HERO_DESCRIPTION,
                style: themeData.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              // Search bar for querying languages or translations.
              SearchBar(
                hintText: 'Langue, traduction ou abréviation',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0.2),
                backgroundColor: WidgetStatePropertyAll(themeData.cardTheme.color),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).updateQuery(value);
                },
              ),
              const SizedBox(height: 20),

              // Featured spotlight banner.
              const SizedBox(width: double.infinity, child: Spotlight()),
              const SizedBox(height: 19),

              // Language catalog section heading.
              Text(
                'Langues du ${Constants.COUNTRY_NAME}',
                style: themeData.textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              
              // Handle loading, error, and data states gracefully from the AsyncValue.
              languagesAsyncValue.when(
                loading: () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => const SkeletonLoader(height: 80),
                ),
                error: (err, stack) => AppErrorView(
                  message: 'Impossible de charger les langues.',
                  onRetry: () => ref.invalidate(languagesProvider),
                ),
                data: (languages) {
                  // Filter the languages based on the search query.
                  final filtered = languages.where((lang) {
                    if (searchQuery.isEmpty) return true;
                    final q = searchQuery.toLowerCase();
                    
                    // Match language name
                    if (lang.name.toLowerCase().contains(q)) return true;
                    if (lang.nativeName.toLowerCase().contains(q)) return true;
                    
                    // Match any Bible translation within the language
                    for (final fileset in lang.filesets) {
                      if (fileset.id.toLowerCase().contains(q)) return true;
                      if (fileset.description.toLowerCase().contains(q)) return true;
                    }
                    
                    return false;
                  }).toList();

                  // Fallback view when no languages match.
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Aucun résultat pour '$searchQuery'.",
                        style: themeData.textTheme.bodyMedium,
                      ),
                    );
                  }
                  
                  // Render items inside SingleChildScrollView using shrinkWrap and disabled scroll physics.
                  return ListView.separated(
                    shrinkWrap: true, // Needed because it's inside a SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final language = filtered[index];
                      return LanguageCard(language: language);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
