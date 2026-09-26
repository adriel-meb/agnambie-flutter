// File: translations_providers.dart
// Purpose: Defines Riverpod providers for fetching Bible translations/editions by language code.
// Author: Adriel
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bible_edition.dart';
import '../../data/repositories/providers.dart';

/// Fetches the list of Bible editions for a given language code.
///
/// Watches [catalogRepositoryProvider] and queries the catalog repository
/// for all [BibleEdition] instances associated with [languageCode].
final biblesProvider = FutureProvider.family<List<BibleEdition>, String>((ref, languageCode) async {
  // Watch the catalog repository instance
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  // Retrieve Bible editions for the given language code
  return catalogRepo.getBiblesForLanguage(languageCode);
});
