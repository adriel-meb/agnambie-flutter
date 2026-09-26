// -----------------------------------------------------------------------------
// File: app.dart
// Purpose: Root application widget configuring top-level navigation, themes,
//          scaffold structure, bottom navigation bar, and persistent mini player.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:agnambie/core/constants/gabon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/settings/settings_providers.dart';

import 'package:agnambie/features/home/home_screen.dart';
import 'package:agnambie/features/offline/offline_screen.dart';
import 'package:agnambie/features/settings/settings_screen.dart';
import 'package:agnambie/features/player/mini_player.dart';

import 'core/constants/theme.dart';

/// The root widget of the Agnambie application.
///
/// Configures [MaterialApp] with light and dark themes, sets up bottom
/// tab navigation between [HomeScreen], [OfflineScreen], and [SettingsScreen],
/// and anchors the global [MiniPlayer] at the bottom of the screen.
class MainApp extends ConsumerStatefulWidget {
  /// Creates the root [MainApp] widget instance.
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  // Current selected tab index in the bottom navigation bar
  int _selectedIndex = 0;

  // Navigation destinations mapped to bottom bar tabs
  final pages = const <Widget>[HomeScreen(), OfflineScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 20,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download_for_offline_outlined),
              activeIcon: Icon(Icons.download_for_offline),
              label: 'Hors ligne',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Réglages',
            ),
          ],
        ),
        body: Column(
          children: [
            // IndexedStack preserves state and scroll positions of inactive tabs
            Expanded(child: IndexedStack(index: _selectedIndex, children: pages)),
            // Persistent audio player docked at bottom of the active screen
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
