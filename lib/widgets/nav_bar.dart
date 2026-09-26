// -----------------------------------------------------------------------------
// File: nav_bar.dart
// Purpose: Reusable application bottom navigation bar widget for screen navigation.
// Author: Agnambie Team
// Creation date: 2026-09-24
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Reusable bottom navigation bar widget for top-level application navigation.
///
/// Provides tab switching between Home, Offline downloads, and Settings screens.
class NavBar extends StatelessWidget {
  /// The index of the currently active tab.
  final int currentIndex;

  /// Callback fired when the user selects a tab index.
  final ValueChanged<int> onTap;

  /// Creates a [NavBar] with the active [currentIndex] and [onTap] callback.
  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 20,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        // Home tab destination
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        // Offline / downloaded content tab destination
        BottomNavigationBarItem(
          icon: Icon(Icons.download_for_offline_outlined),
          activeIcon: Icon(Icons.download_for_offline),
          label: 'Hors ligne',
        ),
        // Settings and preferences tab destination
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Réglages',
        ),
      ],
    );
  }
}
