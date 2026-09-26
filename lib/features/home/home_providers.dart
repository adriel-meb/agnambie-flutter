// Purpose: Riverpod providers supplying data and state for the home feature.
// Author: [Author Placeholder]
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/language.dart';
import '../../data/repositories/providers.dart';

// Fetches the list of available languages for the Home screen.
///
/// Watches the [catalogRepositoryProvider] and retrieves the language catalog asynchronously.
final languagesProvider = FutureProvider<List<Language>>((ref) async {
  // Watch the catalog repository instance to re-fetch if the repository reference changes.
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  // Retrieve the list of available audio Bible languages.
  return catalogRepo.getLanguages();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}
