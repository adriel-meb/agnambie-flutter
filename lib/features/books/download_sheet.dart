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
import '../settings/settings_providers.dart';

/// Displays a modal bottom sheet allowing the user to download audio for [book].
///
/// Computes and presents the estimated download size based on chapter count and
/// active data-saver preferences. Downloads chapters sequentially using [filesetId]
/// and persists them to local storage.
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Téléchargement de ${book.name} commencé (~$sizeFormatted)...',
                        ),
                      ),
                    );

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

                    final catalog = ref.read(catalogRepositoryProvider);
                    final downloader = ref.read(downloadRepositoryProvider);

                    int downloadedCount = 0;
                    int failedCount = 0;

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
                        );
                        downloadedCount++;
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
                        failedCount++;
                        debugPrint('Failed to download ch $chapter: $e');
                      }
                    }

                    if (context.mounted) {
                      if (failedCount == 0 && downloadedCount > 0) {
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
                              '$downloadedCount chapitres téléchargés, $failedCount en échec.',
                            ),
                          ),
                        );
                      } else if (failedCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Échec du téléchargement. Veuillez vérifier votre connexion.',
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
