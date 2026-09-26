// -----------------------------------------------------------------------------
// File: offline_screen.dart
// Purpose: Displays downloaded audio chapters with storage usage and delete actions.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/book_names.dart';
import 'offline_providers.dart';
import '../../data/repositories/providers.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/skeleton.dart';

/// Screen showing the user's downloaded Bible audio content.
///
/// Displays a storage usage summary at the top and a scrollable list of
/// downloaded chapters, each with a delete button that removes both the
/// local file and the Hive database record.
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

          // --- Downloads list ---
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

                return ListView.separated(
                  itemCount: downloads.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = downloads[index];
                    // Resolve human-readable book name (e.g. "MAT" → "Matthew")
                    final bookDisplay = BookNames.getBestName(item.bookId);
                    final sizeMb = (item.sizeInBytes / (1024 * 1024)).toStringAsFixed(1);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.audiotrack_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '$bookDisplay — Chapitre ${item.chapter}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('$sizeMb MB · ${item.bibleId}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        tooltip: 'Supprimer',
                        onPressed: () async {
                          await ref.read(downloadRepositoryProvider).removeDownload(
                            item.bibleId,
                            item.bookId,
                            item.chapter,
                          );
                          // Refresh both providers after deletion
                          ref.invalidate(offlineDownloadsProvider);
                          ref.invalidate(totalStorageUsedProvider);
                        },
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
