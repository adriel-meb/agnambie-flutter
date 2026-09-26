// -----------------------------------------------------------------------------
// File: settings_screen.dart
// Purpose: User-facing settings screen for app preferences and sleep timer.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_providers.dart';

/// A screen widget that displays application settings and preferences.
///
/// Settings are persisted to Hive via Riverpod notifiers and take effect
/// immediately — no Save button required.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen] instance.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowDataMode = ref.watch(lowDataModeProvider);
    final wifiOnly = ref.watch(wifiOnlyModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final autoplay = ref.watch(autoplayProvider);
    final selectedDuration = ref.watch(sleepTimerDurationProvider);
    final remainingSeconds = ref.watch(sleepTimerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          // ── Playback ────────────────────────────────────────────────────
          const _SectionHeader(label: 'Lecture'),

          SwitchListTile(
            title: const Text('Lecture automatique'),
            subtitle: const Text('Passer au chapitre suivant automatiquement.'),
            value: autoplay,
            onChanged: (_) => ref.read(autoplayProvider.notifier).toggle(),
          ),

          // Sleep timer row — shows countdown when active
          ListTile(
            title: const Text('Minuterie de veille'),
            subtitle: Text(
              remainingSeconds != null
                  ? _formatCountdown(remainingSeconds)
                  : 'Arrêter la lecture après un certain temps.',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cancel button only visible while a timer is active
                if (remainingSeconds != null)
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    tooltip: 'Annuler la minuterie',
                    onPressed: () =>
                        ref.read(sleepTimerProvider.notifier).cancel(),
                  ),
                DropdownButton<int>(
                  value: selectedDuration,
                  underline: const SizedBox.shrink(),
                  onChanged: (int? minutes) {
                    if (minutes != null) {
                      ref
                          .read(sleepTimerDurationProvider.notifier)
                          .setDuration(minutes);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Désactivé')),
                    DropdownMenuItem(value: 15, child: Text('15 min')),
                    DropdownMenuItem(value: 30, child: Text('30 min')),
                    DropdownMenuItem(value: 60, child: Text('60 min')),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // ── Réseau & données ────────────────────────────────────────────
          const _SectionHeader(label: 'Réseau & données'),

          SwitchListTile(
            title: const Text('Mode données réduites'),
            subtitle: const Text(
              'Utilise des fichiers audio compressés (opus16) pour économiser les données.',
            ),
            value: lowDataMode,
            onChanged: (_) =>
                ref.read(lowDataModeProvider.notifier).toggle(),
          ),

          SwitchListTile(
            title: const Text('Téléchargement en Wi-Fi uniquement'),
            subtitle: const Text(
              'Évite de consommer des données mobiles pour télécharger.',
            ),
            value: wifiOnly,
            onChanged: (_) =>
                ref.read(wifiOnlyModeProvider.notifier).toggle(),
          ),

          const Divider(),

          // ── Apparence ───────────────────────────────────────────────────
          const _SectionHeader(label: 'Apparence'),

          ListTile(
            title: const Text('Thème'),
            subtitle: const Text('Apparence de l\'application'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox.shrink(),
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Système'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Clair'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Sombre'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a countdown in seconds as "MM:SS" for the sleep timer subtitle.
  String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return 'Arrêt dans ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// A simple section header for grouping settings visually.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
