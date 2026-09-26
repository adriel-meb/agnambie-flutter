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
  final String? language;
  final List<Download> chapters;

  _GroupedBookDownloads({
    required this.bibleId,
    required this.bookId,
    this.bibleVersion,
    this.bibleName,
    this.language,
    required this.chapters,
  });

  int get totalBytes => chapters.fold<int>(0, (sum, item) => sum + item.sizeInBytes);
}

/// Resolves a human-readable language name from saved metadata or Bible ID prefix.
String _resolveLanguage(String? language, String bibleId) {
  if (language != null && language.trim().isNotEmpty) {
    return language.trim();
  }
  final upper = bibleId.toUpperCase();
  if (upper.startsWith('FAN')) return 'Fang';
  if (upper.startsWith('MYE')) return 'Myène';
  if (upper.startsWith('PUU')) return 'Punu';
  if (upper.startsWith('NZB')) return 'Nzebi';
  if (upper.startsWith('FRA') || upper.startsWith('FRN')) return 'Français';
  if (upper.startsWith('BKW')) return 'Bekwel';
  if (upper.startsWith('BBG')) return 'Barama';
  if (upper.startsWith('BUW')) return 'Bubi';
  if (upper.startsWith('DMA')) return 'Duma';
  if (upper.startsWith('KEB')) return 'Kélé';
  if (upper.startsWith('LUP')) return 'Lumbu';
  if (upper.startsWith('ZMN')) return 'Mbangwe';
  if (upper.startsWith('NMD')) return 'Ndumu';
  if (upper.startsWith('PIC')) return 'Pinji';
  if (upper.startsWith('TSV')) return 'Tsogo';
  if (upper.startsWith('VIF')) return 'Vili';
  if (upper.startsWith('SYX')) return 'Samay';
  if (upper.startsWith('SYI')) return 'Seki';
  if (upper.startsWith('BNG')) return 'Benga';
  return '';
}

/// Resolves a version abbreviation or label from saved metadata or Bible ID pattern.
String _resolveVersion(String? bibleVersion, String bibleId, String? bibleName) {
  // If a descriptive custom version is saved and distinct from raw ID, use it
  if (bibleVersion != null &&
      bibleVersion.trim().isNotEmpty &&
      bibleVersion != bibleId) {
    return '$bibleVersion ($bibleId)';
  }
  final upper = bibleId.toUpperCase();
  if (upper.contains('BSG')) {
    return 'BSG ($bibleId)';
  }
  if (upper.contains('TLS') || upper.contains('LSN') || upper.contains('LSG')) {
    return 'LSG ($bibleId)';
  }
  if (upper.contains('PDV') || upper.contains('PDC')) {
    return 'PDV ($bibleId)';
  }
  if (upper.contains('DPI')) {
    return 'DPI ($bibleId)';
  }
  if (upper.contains('UBS')) {
    return 'UBS ($bibleId)';
  }
  if (upper.contains('CIE')) {
    return 'CIE ($bibleId)';
  }
  if (upper.contains('WBT')) {
    return 'WBT ($bibleId)';
  }
  if (bibleName != null && bibleName.trim().isNotEmpty) {
    return '$bibleName ($bibleId)';
  }
  return bibleId;
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
                    final resolvedLang = _resolveLanguage(item.language, item.bibleId);
                    groupedMap[groupKey] = _GroupedBookDownloads(
                      bibleId: item.bibleId,
                      bookId: item.bookId,
                      bibleVersion: item.bibleVersion,
                      bibleName: item.bibleName,
                      language: resolvedLang,
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
                    final String versionText = _resolveVersion(
                      group.bibleVersion,
                      group.bibleId,
                      group.bibleName,
                    );

                    final resolvedLang = _resolveLanguage(group.language, group.bibleId);
                    final languagePrefix = resolvedLang.isNotEmpty
                        ? '$resolvedLang · '
                        : '';

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
                          '$languagePrefix$sizeMb MB · $versionText · $chapterCountText',
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
                                      languageIso: group.language ?? '',
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
