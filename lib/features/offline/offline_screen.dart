// -----------------------------------------------------------------------------
// File: offline_screen.dart
// Purpose: Displays downloaded audio chapters grouped by book with expandable dropdowns.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/book_names.dart';
import '../../data/models/download.dart';
import '../../data/repositories/providers.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/skeleton.dart';
import '../player/player_controller.dart';
import '../player/player_screen.dart';
import 'offline_providers.dart';

/// Helper model representing a collection of downloaded chapters grouped by book.
class _GroupedBookDownloads {
  final String bibleId;
  final String bookId;
  final String? bibleVersion;
  final String? bibleName;
  final List<Download> chapters;

  _GroupedBookDownloads({
    required this.bibleId,
    required this.bookId,
    this.bibleVersion,
    this.bibleName,
    required this.chapters,
  });

  int get totalBytes => chapters.fold<int>(0, (sum, item) => sum + item.sizeInBytes);
}

/// Screen showing the user's downloaded Bible audio content grouped by book.
///
/// Displays a storage usage summary at the top and expandable cards per book,
/// allowing users to browse chapters in a dropdown style, play them directly,
/// or delete individual chapters as well as entire books.
class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(offlineDownloadsProvider);
    final storageAsync = ref.watch(totalStorageUsedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
      ),
      body: Column(
        children: [
          // --- Storage usage banner ---
          storageAsync.when(
            data: (bytes) {
              final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(Icons.storage_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      '$mb MB utilisés',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SkeletonLoader(height: 48, borderRadius: BorderRadius.zero),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // --- Downloads list grouped by book ---
          Expanded(
            child: downloadsAsync.when(
              data: (downloads) {
                if (downloads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download_done_rounded, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun téléchargement',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vos chapitres téléchargés apparaîtront ici.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group downloads by bibleId and bookId
                final Map<String, _GroupedBookDownloads> groupedMap = {};
                for (final item in downloads) {
                  final groupKey = '${item.bibleId}_${item.bookId}';
                  if (!groupedMap.containsKey(groupKey)) {
                    groupedMap[groupKey] = _GroupedBookDownloads(
                      bibleId: item.bibleId,
                      bookId: item.bookId,
                      bibleVersion: item.bibleVersion,
                      bibleName: item.bibleName,
                      chapters: <Download>[],
                    );
                  }
                  groupedMap[groupKey]!.chapters.add(item);
                }

                // Sort chapters numerically inside each book group
                for (final group in groupedMap.values) {
                  group.chapters.sort((a, b) => a.chapter.compareTo(b.chapter));
                }
                final groupedBooks = groupedMap.values.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: groupedBooks.length,
                  itemBuilder: (context, index) {
                    final group = groupedBooks[index];
                    final bookDisplay = BookNames.getBestName(group.bookId);
                    final sizeMb = (group.totalBytes / (1024 * 1024)).toStringAsFixed(1);

                    // Build version label: version abbreviation with fileset ID or fallback
                    final String versionText;
                    if (group.bibleVersion != null && group.bibleVersion!.isNotEmpty) {
                      if (group.bibleVersion == group.bibleId) {
                        versionText = group.bibleVersion!;
                      } else {
                        versionText = '${group.bibleVersion} (${group.bibleId})';
                      }
                    } else {
                      versionText = group.bibleId;
                    }

                    final chapterCountText =
                        '${group.chapters.length} ${group.chapters.length > 1 ? 'chapitres' : 'chapitre'}';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          bookDisplay,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          '$sizeMb MB · $versionText · $chapterCountText',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                              tooltip: 'Supprimer tout le livre',
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Supprimer $bookDisplay ?'),
                                    content: Text(
                                      'Voulez-vous supprimer tous les $chapterCountText de $bookDisplay ($sizeMb MB) ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref.read(downloadRepositoryProvider).removeBookDownloads(
                                        group.bibleId,
                                        group.bookId,
                                      );
                                  ref.invalidate(offlineDownloadsProvider);
                                  ref.invalidate(totalStorageUsedProvider);
                                }
                              },
                            ),
                            const Icon(Icons.expand_more_rounded),
                          ],
                        ),
                        children: [
                          const Divider(height: 1),
                          ...group.chapters.map((chapterItem) {
                            final chSizeMb =
                                (chapterItem.sizeInBytes / (1024 * 1024)).toStringAsFixed(1);
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              leading: Icon(
                                Icons.play_circle_outline_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              title: Text(
                                'Chapitre ${chapterItem.chapter}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('$chSizeMb MB'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                tooltip: 'Supprimer ce chapitre',
                                onPressed: () async {
                                  await ref.read(downloadRepositoryProvider).removeDownload(
                                        chapterItem.bibleId,
                                        chapterItem.bookId,
                                        chapterItem.chapter,
                                      );
                                  ref.invalidate(offlineDownloadsProvider);
                                  ref.invalidate(totalStorageUsedProvider);
                                },
                              ),
                              onTap: () {
                                ref.read(playerControllerProvider.notifier).playChapter(
                                      languageIso: '',
                                      bibleId: chapterItem.bibleId,
                                      filesetId: chapterItem.bibleId,
                                      bookId: chapterItem.bookId,
                                      bookName: bookDisplay,
                                      chapter: chapterItem.chapter,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => const PlayerScreen(),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 5,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SkeletonLoader(height: 72),
                ),
              ),
              error: (err, _) => AppErrorView(
                message: 'Impossible de charger vos téléchargements.',
                onRetry: () => ref.invalidate(offlineDownloadsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
