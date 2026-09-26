// -----------------------------------------------------------------------------
// File: main.dart
// Purpose: Application entry point responsible for initializing Flutter engine
//          bindings, background audio services, and Riverpod state management.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'data/repositories/audio_handler.dart';
import 'data/repositories/providers.dart';

/// Application entry point.
///
/// Ensures Flutter engine bindings are initialized, boots the platform-level
/// [AudioService] with [AppAudioHandler], configures Riverpod [ProviderScope]
/// dependency injection overrides, and runs [MainApp].
Future<void> main() async {
  // Required for asynchronous platform channel operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local caching/storage
  await Hive.initFlutter();

  // Initialize the API client (and its ETag cache store)
  await ApiClient.init();

  // Initialize the audio service globally before the app starts
  final audioHandler = await AudioService.init(
    builder: AppAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.agnambie.app.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Provide the fully initialized audio handler directly
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const MainApp(),
    ),
  );
}
