// File: settings_providers.dart
// Purpose: Riverpod notifiers for persisting user settings via Hive, and the sleep timer.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/repositories/providers.dart';

// ---------------------------------------------------------------------------
// Low data mode
// ---------------------------------------------------------------------------

final lowDataModeProvider =
    NotifierProvider<LowDataModeNotifier, bool>(LowDataModeNotifier.new);

/// Persists and exposes the "low data mode" setting.
class LowDataModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = box.get('lowDataMode', defaultValue: false)!;
  }

  Future<void> toggle() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = !state;
    await box.put('lowDataMode', state);
  }
}

// ---------------------------------------------------------------------------
// Wi-Fi only mode
// ---------------------------------------------------------------------------

final wifiOnlyModeProvider =
    NotifierProvider<WifiOnlyModeNotifier, bool>(WifiOnlyModeNotifier.new);

/// Persists and exposes the "Wi-Fi only downloads" setting.
class WifiOnlyModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // Defaults to true for safety
  }

  Future<void> _load() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = box.get('wifiOnlyMode', defaultValue: true)!;
  }

  Future<void> toggle() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = !state;
    await box.put('wifiOnlyMode', state);
  }
}

// ---------------------------------------------------------------------------
// Theme mode
// ---------------------------------------------------------------------------

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Persists and exposes the app [ThemeMode] setting.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final box = await Hive.openBox<int>('settings_ints');
    final index = box.get('themeMode', defaultValue: ThemeMode.system.index)!;
    state = ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final box = await Hive.openBox<int>('settings_ints');
    state = mode;
    await box.put('themeMode', mode.index);
  }
}

// ---------------------------------------------------------------------------
// Autoplay
// ---------------------------------------------------------------------------

final autoplayProvider =
    NotifierProvider<AutoplayNotifier, bool>(AutoplayNotifier.new);

/// Persists and exposes the "autoplay next chapter" setting.
class AutoplayNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = box.get('autoplay', defaultValue: true)!;
  }

  Future<void> toggle() async {
    final box = await Hive.openBox<bool>('settings_bools');
    state = !state;
    await box.put('autoplay', state);
  }
}

// ---------------------------------------------------------------------------
// Sleep timer
// ---------------------------------------------------------------------------

/// The currently selected sleep timer duration in minutes.
/// Zero means the timer is disabled.
final sleepTimerDurationProvider =
    NotifierProvider<SleepTimerDurationNotifier, int>(
      SleepTimerDurationNotifier.new,
    );

/// Manages the selected sleep timer duration and persists it to Hive.
class SleepTimerDurationNotifier extends Notifier<int> {
  @override
  int build() => 0; // Off by default; not persisted across sessions intentionally

  /// Sets the duration and restarts the timer via [SleepTimerNotifier].
  void setDuration(int minutes) {
    state = minutes;
    ref.read(sleepTimerProvider.notifier).restart(minutes);
  }
}

/// Exposes the remaining seconds on the active sleep timer, or null when off.
final sleepTimerProvider =
    NotifierProvider<SleepTimerNotifier, int?>(SleepTimerNotifier.new);

/// Counts down from the selected duration and pauses audio when it reaches zero.
///
/// Uses a periodic [Timer] that ticks every second and decrements [state].
/// When [state] reaches 0 it pauses playback via [playerRepositoryProvider].
class SleepTimerNotifier extends Notifier<int?> {
  Timer? _timer;

  @override
  int? build() {
    // Cancel the timer when the provider is disposed (e.g. app restart)
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// Starts (or restarts) the sleep timer for [minutes] minutes.
  /// Passing 0 cancels any running timer.
  void restart(int minutes) {
    _timer?.cancel();
    _timer = null;

    if (minutes <= 0) {
      state = null;
      return;
    }

    state = minutes * 60; // Convert to seconds for the countdown display

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state;
      if (remaining == null || remaining <= 1) {
        _timer?.cancel();
        _timer = null;
        state = null;
        // Reset the duration selector back to "off"
        ref.read(sleepTimerDurationProvider.notifier).state = 0;
        // Pause playback
        ref.read(playerRepositoryProvider).pause();
      } else {
        state = remaining - 1;
      }
    });
  }

  /// Cancels the sleep timer without pausing playback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    state = null;
    ref.read(sleepTimerDurationProvider.notifier).state = 0;
  }
}
