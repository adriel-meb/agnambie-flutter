// File: seek_bar.dart
// Purpose: Displays the seek bar and time labels for the audio player.
// Author: Placeholder
// Creation date: 2026-09-26
// Last modified: 2026-09-26

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// A widget displaying a slider and duration text for tracking and seeking [player] position.
class SeekBar extends StatelessWidget {
  /// The audio player instance.
  final AudioPlayer player;

  /// Creates a [SeekBar] instance.
  const SeekBar({super.key, required this.player});

  /// Formats a [Duration] into standard time format (`mm:ss` or `hh:mm:ss`).
  ///
  /// Returns `"00:00"` when the given duration is null.
  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    // Include hour segment only if track duration exceeds 60 minutes
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: const SliderThemeData(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Color(0xFF34d399),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                // Clamp value between 0 and duration to avoid slider assertions
                // when position temporarily reports higher than duration during buffering
                value: position.inMilliseconds
                    .toDouble()
                    .clamp(0, duration.inMilliseconds.toDouble()),
                max: duration.inMilliseconds > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  player.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            // Time labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(_formatDuration(duration),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
