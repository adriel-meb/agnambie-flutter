// -----------------------------------------------------------------------------
// File: settings_screen.dart
// Purpose: User-facing settings screen for app preferences, sleep timer, and developer contact.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_providers.dart';

/// A screen widget that displays application settings and preferences.
///
/// Settings are persisted to Hive via Riverpod notifiers and take effect
/// immediately — no Save button required.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen] instance.
  const SettingsScreen({super.key});

  /// Opens the default mail application to write to the developer,
  /// or presents a fallback contact sheet if no mail client responds.
  Future<void> _contactDeveloper(BuildContext context) async {
    const email = 'adrix92@live.fr';
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=[Agnambie] Contact / Retours',
    );

    try {
      final launched = await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showContactSheet(context, email);
      }
    } catch (_) {
      if (context.mounted) {
        _showContactSheet(context, email);
      }
    }
  }

  /// Displays a modal bottom sheet with the developer contact email and a copy button.
  void _showContactSheet(BuildContext context, String email) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacter le développeur',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous pouvez nous contacter directement à l\'adresse suivante :',
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(sheetContext).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectableText(
                          email,
                          style: Theme.of(sheetContext).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copier l\'adresse',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: email));
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Adresse e-mail copiée dans le presse-papiers.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

          const Divider(),

          // ── Support & Contact ───────────────────────────────────────────
          const _SectionHeader(label: 'Support & Contact'),

          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Contacter le développeur'),
            subtitle: const Text('Une question, suggestion ou problème ? Écrivez-nous.'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _contactDeveloper(context),
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

/// A section header for grouping settings visually with strong typography.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
