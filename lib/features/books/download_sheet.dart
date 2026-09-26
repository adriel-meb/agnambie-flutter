import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics_service.dart';
import '../../data/models/bible_edition.dart';
import '../../data/models/book.dart';
import '../../data/repositories/providers.dart';
import '../settings/settings_providers.dart';


void showDownloadSheet(BuildContext context, BibleEdition bible, Book book, String filesetId) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Télécharger ${book.name}'),
                  subtitle: const Text('Options de téléchargement'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Télécharger tout le livre'),
                  onTap: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Téléchargement commencé...')),
                    );
                    
                    final isWifiOnly = ref.read(wifiOnlyModeProvider);
                    if (isWifiOnly) {
                      final result = await Connectivity().checkConnectivity();
                      if (!result.contains(ConnectivityResult.wifi)) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Connectez-vous au Wi-Fi pour télécharger.')),
                          );
                        }
                        return;
                      }
                    }

                    final catalog = ref.read(catalogRepositoryProvider);
                    final downloader = ref.read(downloadRepositoryProvider);
                    
                    for (final rawChapter in book.chapters) {
                      final chapter = rawChapter as int;
                      try {
                        final url = await catalog.getChapterAudioUrl(
                           bible.language, bible.abbr, book.bookId, chapter
                        );
                        await downloader.downloadChapter(url, bible.abbr, book.bookId, chapter);
                        unawaited(
                          ref.read(analyticsServiceProvider).logEvent('chapter_downloaded', {
                            'language_iso': bible.language,
                            'bible_id': bible.abbr,
                            'book_id': book.bookId,
                            'chapter': chapter,
                          }),
                        );
                      } catch (e) {
                         debugPrint('Failed to download ch $chapter: $e');
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
