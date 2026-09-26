// -----------------------------------------------------------------------------
// File: analytics_service.dart
// Purpose: Offline-batched event logger that records client analytics to Hive
//          and flushes them in a single HTTP request when connectivity is available.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../network/api_client.dart';

/// Service responsible for recording user engagement and telemetry offline,
/// batching them in local storage, and syncing them when online.
class AnalyticsService {
  static const String _boxName = 'analytics_events';
  static const int _maxBatchFlushThreshold = 20;

  final ApiClient _apiClient;
  final Connectivity _connectivity;

  bool _isFlushing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Creates a new [AnalyticsService] instance.
  AnalyticsService({
    ApiClient? apiClient,
    Connectivity? connectivity,
  })  : _apiClient = apiClient ?? ApiClient(),
        _connectivity = connectivity ?? Connectivity();

  /// Logs a user or system event into the local offline queue.
  ///
  /// The event is recorded immediately to Hive with a UTC timestamp.
  /// If the queue exceeds [_maxBatchFlushThreshold], a background flush
  /// is scheduled automatically.
  Future<void> logEvent(String name, [Map<String, dynamic>? properties]) async {
    try {
      final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
      final event = <String, dynamic>{
        'name': name,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        if (properties != null && properties.isNotEmpty) 'properties': properties,
      };

      await box.add(event);

      // Trigger background flush if accumulated events reach threshold
      if (box.length >= _maxBatchFlushThreshold) {
        unawaited(flush());
      }
    } catch (e) {
      // Analytics failures must never crash the main application
      debugPrint('[Analytics] Failed to record event "$name": $e');
    }
  }

  /// Flushes all queued offline events in a single batch to the backend.
  ///
  /// If the device is offline or the server fails, events are retained
  /// in Hive and retried on the next connectivity transition.
  Future<void> flush() async {
    if (_isFlushing) return;

    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none) && results.length == 1) {
        // Device is currently completely offline; hold queue
        return;
      }

      final box = await Hive.openBox<Map<String, dynamic>>(_boxName);
      if (box.isEmpty) return;

      _isFlushing = true;

      // Extract all queued events preserving order
      final events = <Map<String, dynamic>>[];
      for (var i = 0; i < box.length; i++) {
        final item = box.getAt(i);
        if (item != null) {
          events.add(Map<String, dynamic>.from(item));
        }
      }

      if (events.isEmpty) {
        _isFlushing = false;
        return;
      }

      // Send the batch payload in a single HTTP request
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/metrics',
        data: events,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully accepted by server — safely clear flushed events
        await box.clear();
      }
    } catch (e) {
      debugPrint('[Analytics] Batch sync failed (will retry): $e');
    } finally {
      _isFlushing = false;
    }
  }

  /// Initializes background connectivity listener to automatically flush
  /// queued telemetry whenever network connectivity is restored.
  void initAutoFlush() {
    // Initial flush attempt on app start
    unawaited(flush());

    // Listen for transitions from offline to online
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        unawaited(flush());
      }
    });
  }

  /// Disposes any active streams or listeners.
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}

/// Global provider for accessing [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final service = AnalyticsService();
  service.initAutoFlush();
  ref.onDispose(service.dispose);
  return service;
});
