// File: playback_controls.dart
// Purpose: Displays the play/pause and skip buttons for the audio player.
// Author: Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// A widget displaying interactive playback controls for the [player].
class PlaybackControls extends StatelessWidget {
  /// The audio player instance.
  final AudioPlayer player;

  /// Creates a [PlaybackControls] instance.
  const PlaybackControls({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10_rounded),
          color: Colors.white,
          iconSize: 32,
          onPressed: () {
            // Seek backward by 10 seconds, preventing negative playback position
            final newPos = player.position - const Duration(seconds: 10);
            player.seek(newPos < Duration.zero ? Duration.zero : newPos);
          },
        ),

        // Main Play/Pause Button
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing ?? false;

            // Display buffering spinner while loading or buffering audio stream
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                      color: Color(0xFF14271d), strokeWidth: 3),
                ),
              );
            }

            return InkWell(
              onTap: () {
                if (playing) {
                  player.pause();
                } else {
                  // If audio has reached the end, rewind to beginning before replaying
                  if (processingState == ProcessingState.completed) {
                    player.seek(Duration.zero);
                  }
                  player.play();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: const Color(0xFF14271d),
                  size: 48,
                ),
              ),
            );
          },
        ),

        IconButton(
          icon: const Icon(Icons.forward_10_rounded),
          color: Colors.white,
          iconSize: 32,
          onPressed: () {
            // Seek forward by 10 seconds
            final newPos = player.position + const Duration(seconds: 10);
            player.seek(newPos);
          },
        ),
      ],
    );
  }
}
