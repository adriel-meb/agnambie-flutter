// -----------------------------------------------------------------------------
// Purpose: Persistent mini audio player bar displayed at the bottom of the screen.
// Author: Author Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/utils/book_names.dart';
import '../../data/repositories/providers.dart';
import 'player_controller.dart';
import 'player_screen.dart';

/// Compact bottom audio player bar displaying the current track info
/// and quick play/pause control.
///
/// Tapping the bar presents the full-screen [PlayerScreen] as a modal dialog.
/// Automatically hides (renders [SizedBox.shrink]) if no audio track is active.
class MiniPlayer extends ConsumerWidget {
  /// Creates a new [MiniPlayer] widget.
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(playerControllerProvider);
    // If no track is currently loaded or selected, collapse completely
    if (track == null) return const SizedBox.shrink();

    final playerRepo = ref.watch(playerRepositoryProvider);
    final player = playerRepo.player;


    return GestureDetector(
      onTap: () {
        // Open full player screen modally
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const PlayerScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF14271d), // Match player background
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Row(
          children: [
            // Track Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BookNames.getBestName(track.bookId, apiName: track.bookName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chapitre ${track.chapter} · ${track.bibleId}',
                      style: const TextStyle(
                        color: Color(0xFF6ee7b7), // Emerald 300
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Play/Pause Button
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing ?? false;

                // Show mini progress indicator while loading or buffering
                if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  );
                }

                return IconButton(
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  color: Colors.white,
                  iconSize: 32,
                  onPressed: () {
                    if (playing) {
                      player.pause();
                    } else {
                      // Restart from beginning if playback finished previously
                      if (processingState == ProcessingState.completed) {
                        player.seek(Duration.zero);
                      }
                      player.play();
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: Colors.white54,
              iconSize: 24,
              onPressed: () {
                ref.read(playerControllerProvider.notifier).close();
              },
            ),
          ],
        ),
      ),
    );
  }
}
