// -----------------------------------------------------------------------------
// Purpose: Full-screen audio player presentation widget with playback controls.
// Author: Author Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/providers.dart';
import 'player_controller.dart';
import 'widgets/playback_controls.dart';
import 'widgets/seek_bar.dart';
import 'widgets/track_info.dart';

/// Full-screen audio player UI displaying artwork, track details, seek slider,
/// and interactive playback controls (play/pause, seek back, seek forward).
class PlayerScreen extends ConsumerStatefulWidget {
  /// Creates a new [PlayerScreen] instance.
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for playback errors after the first frame so the widget tree is
    // fully mounted before we try to show a SnackBar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<String?>(playerErrorProvider, (String? previous, String? next) {
        if (next != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(playerErrorProvider.notifier).clear();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(playerControllerProvider);
    final playerRepo = ref.watch(playerRepositoryProvider);
    final player = playerRepo.player;

    // Display a loading indicator if navigated to before a track is ready
    if (track == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF14271d),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF14271d),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () {
              ref.read(playerControllerProvider.notifier).close();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrackInfo(track: track),
              const SizedBox(height: 32),
              SeekBar(player: player),
              const SizedBox(height: 16),
              PlaybackControls(player: player),
            ],
          ),
        ),
      ),
    );
  }
}
