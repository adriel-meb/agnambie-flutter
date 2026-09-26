// -----------------------------------------------------------------------------
// File: download_sheet.dart
// Purpose: Modal bottom sheet allowing users to download audio chapters for offline listening.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics_service.dart';
import '../../data/models/bible_edition.dart';
import '../../data/models/book.dart';
import '../../data/repositories/providers.dart';
import '../offline/offline_providers.dart';
import '../settings/settings_providers.dart';
import 'download_providers.dart';

/// Displays a modal bottom sheet allowing the user to download audio for [book].
///
/// Computes and presents the estimated download size based on chapter count and
/// active data-saver preferences. Downloads chapters sequentially using [filesetId],
/// streams live progression through [bookDownloadProgressProvider], and updates
/// offline storage caches upon completion.
void showDownloadSheet(
  BuildContext context,
  BibleEdition bible,
  Book book,
  String filesetId,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final isLowData = ref.watch(lowDataModeProvider);
          final chapterCount = book.chapters.length;

          // Average chapter size in MB: standard MP3 is ~3.5 MB, opus16 is ~1.2 MB
          final avgChapterMb = isLowData ? 1.2 : 3.5;
          final totalMb = chapterCount * avgChapterMb;
          final sizeFormatted = totalMb >= 1000
              ? '${(totalMb / 1024).toStringAsFixed(1)} Go'
              : totalMb >= 10
                  ? '${totalMb.toStringAsFixed(0)} Mo'
                  : '${totalMb.toStringAsFixed(1)} Mo';

          final theme = Theme.of(context);
          final downloadKey = bookDownloadKey(filesetId, book.bookId);

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Télécharger ${book.name}',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    chapterCount > 1
                        ? '$chapterCount chapitres disponibles'
                        : '1 chapitre disponible',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Télécharger tout le livre'),
                  subtitle: Text(
                    chapterCount > 1
                        ? '$chapterCount chapitres · ~$sizeFormatted'
                        : '1 chapitre · ~$sizeFormatted',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '~$sizeFormatted',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final isWifiOnly = ref.read(wifiOnlyModeProvider);
                    if (isWifiOnly) {
                      final result = await Connectivity().checkConnectivity();
                      if (!result.contains(ConnectivityResult.wifi)) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Connectez-vous au Wi-Fi pour télécharger.',
                              ),
                            ),
                          );
                        }
                        return;
                      }
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Téléchargement de ${book.name} commencé (~$sizeFormatted)...',
                        ),
                      ),
                    );

                    final catalog = ref.read(catalogRepositoryProvider);
                    final downloader = ref.read(downloadRepositoryProvider);
                    final progressNotifier =
                        ref.read(bookDownloadProgressProvider.notifier);

                    progressNotifier.startDownload(downloadKey, chapterCount);

                    int downloadedCount = 0;
                    String? lastErrorMessage;

                    for (final rawChapter in book.chapters) {
                      final chapter = rawChapter as int;
                      try {
                        final url = await catalog.getChapterAudioUrl(
                          bible.language,
                          filesetId,
                          book.bookId,
                          chapter,
                        );
                        await downloader.downloadChapter(
                          url,
                          filesetId,
                          book.bookId,
                          chapter,
                          bibleVersion: bible.abbr.isNotEmpty ? bible.abbr : bible.name,
                          bibleName: bible.name,
                          language: bible.language,
                        );
                        downloadedCount++;
                        progressNotifier.updateProgress(downloadKey, downloadedCount);

                        // Invalidate caches so offline list and storage indicators refresh immediately
                        ref.invalidate(offlineDownloadsProvider);
                        ref.invalidate(totalStorageUsedProvider);

                        unawaited(
                          ref.read(analyticsServiceProvider).logEvent(
                            'chapter_downloaded',
                            {
                              'language_iso': bible.language,
                              'fileset_id': filesetId,
                              'bible_id': bible.abbr,
                              'book_id': book.bookId,
                              'chapter': chapter,
                            },
                          ),
                        );
                      } catch (e) {
                        lastErrorMessage = e.toString();
                        debugPrint('Failed to download ch $chapter: $e');
                        // Notify error on the first failure or continue attempting remaining chapters
                      }
                    }

                    // Invalidate caches so offline list and storage indicators refresh immediately
                    ref.invalidate(offlineDownloadsProvider);
                    ref.invalidate(totalStorageUsedProvider);

                    if (lastErrorMessage != null) {
                      progressNotifier.setError(downloadKey, lastErrorMessage);
                    } else {
                      progressNotifier.finishDownload(downloadKey);
                    }

                    if (context.mounted) {
                      if (lastErrorMessage == null && downloadedCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${book.name} téléchargé avec succès ($downloadedCount chapitres).',
                            ),
                          ),
                        );
                      } else if (downloadedCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$downloadedCount/${book.chapters.length} chapitres téléchargés. Erreur sur certains chapitres.',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade800,
                            content: Text(
                              'Échec du téléchargement de ${book.name} : ${lastErrorMessage ?? "erreur réseau"}.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
