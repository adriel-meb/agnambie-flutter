// -----------------------------------------------------------------------------
// File: app_error_view.dart
// Purpose: Reusable friendly error display widget with optional retry action.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// A standardized user-facing error view.
///
/// Replaces raw error messages with clean, localized text in French,
/// an illustrative error icon, and an optional retry button.
class AppErrorView extends StatelessWidget {
  /// The primary error message presented to the user.
  final String message;

  /// Optional secondary details or suggestions (e.g. check internet connection).
  final String? subtitle;

  /// Callback executed when the user taps the retry button.
  /// If null, no retry button is rendered.
  final VoidCallback? onRetry;

  /// Creates a new [AppErrorView] instance.
  const AppErrorView({
    super.key,
    this.message = 'Impossible de charger les données.',
    this.subtitle = 'Vérifiez votre connexion internet et réessayez.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 54,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
