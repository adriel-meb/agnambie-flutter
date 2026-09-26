// =============================================================================
// File: providers.dart
// Purpose: Defines Riverpod dependency injection providers for repositories, registries, and audio services.
// Author: Contributor
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'catalog_repository.dart';
import 'player_repository.dart';
import '../sources/source_registry.dart';


import 'audio_handler.dart';
import 'download_repository.dart';
import '../datasources/downloads_local.dart';
import '../../core/network/api_client.dart';


/// Provides a singleton-like instance of [SourceRegistry].
///
/// Responsible for routing audio catalog requests to the appropriate backend
/// data source (e.g., Bible Brain).
final sourceRegistryProvider = Provider<SourceRegistry>((ref) {
  return SourceRegistry();
});

/// Provides the [CatalogRepository] instance, injecting the active [SourceRegistry].
///
/// Reacts to changes in [sourceRegistryProvider] to ensure catalog requests are
/// routed properly.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  // Watch registry dependency so repository updates if registry configuration changes
  final registry = ref.watch(sourceRegistryProvider);
  return CatalogRepository(sourceRegistry: registry);
});

/// Provides the [AppAudioHandler].
///
/// Must be overridden in `main.dart` with the initialized instance before [runApp] is called.
final audioHandlerProvider = Provider<AppAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider was not overridden in ProviderScope');
});

/// Provides the [PlayerRepository] instance.
///
/// Requires [audioHandlerProvider] to have completed initialization before this
/// provider is accessed. Watches [catalogRepositoryProvider] and binds playback
/// commands to the initialized [AppAudioHandler].
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  // Watch catalog repository for audio stream resolution
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  
  // We read the initialized handler from the provider.
  // It is guaranteed to be loaded because we override it in main.
  final handler = ref.watch(audioHandlerProvider);

  final repo = PlayerRepository(
    catalogRepository: catalogRepo,
    downloadRepository: ref.watch(downloadRepositoryProvider),
    audioHandler: handler,
  );
  
  // Clean up player resources when provider scope is destroyed
  ref.onDispose(repo.dispose);
  return repo;
});


final downloadsLocalDataSourceProvider = Provider<DownloadsLocalDataSource>((ref) {
  return HiveDownloadsLocalDataSource();
});

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  final localData = ref.watch(downloadsLocalDataSourceProvider);
  return DownloadRepository(localData, ApiClient().dio);
});
