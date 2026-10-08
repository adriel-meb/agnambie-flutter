// -----------------------------------------------------------------------------
// File: api_client.dart
// Purpose: Configures and manages the singleton HTTP client (Dio) for network
//          requests, including base URL resolution, timeouts, and error handling.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-10-08
// -----------------------------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'api_exception.dart';
import 'api_logger.dart';

/// Provides a configured Dio instance for the entire app.
/// 
/// Base URL points to the local backend proxy. Add interceptors here for
/// logging, timeout config, and any required headers.
class ApiClient {
  // Singleton pattern for the whole app
  static ApiClient? _instance;
  
  /// The underlying [Dio] HTTP client configured with defaults and interceptors.
  late final Dio dio;

  /// Factory constructor returning the singleton [ApiClient] instance.
  factory ApiClient() {
    if (_instance == null) {
      throw StateError('ApiClient is not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initializes the API client and its local caching database.
  static Future<void> init() async {
    if (_instance != null) return;
    
    String? cachePath;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      cachePath = dir.path;
    }
    
    _instance = ApiClient._internal(cachePath);
  }

  ApiClient._internal(String? cachePath) {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ETag caching interceptor
    final cacheStore = cachePath != null 
        ? HiveCacheStore(cachePath) 
        : MemCacheStore();
        
    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra['startTime'] = DateTime.now();
          ApiLogger.logRequest(options);
          try {
             if (Hive.isBoxOpen('settings_bools')) {
               final box = Hive.box<bool>('settings_bools');
               final lowDataMode = box.get('lowDataMode', defaultValue: false)!;
               if (lowDataMode) {
                 options.headers['Save-Data'] = 'on';
               }
             } else {
               final box = await Hive.openBox<bool>('settings_bools');
               final lowDataMode = box.get('lowDataMode', defaultValue: false)!;
               if (lowDataMode) {
                 options.headers['Save-Data'] = 'on';
               }
             }
          } catch (_) {}
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['startTime'] as DateTime?;
          final duration = start != null ? DateTime.now().difference(start) : Duration.zero;
          ApiLogger.logResponse(response, duration);
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final start = e.requestOptions.extra['startTime'] as DateTime?;
          final duration = start != null ? DateTime.now().difference(start) : null;
          ApiLogger.logError(e, duration);
          
          // Transform DioException into our typed ApiException
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError) {
            
            final networkError = NetworkException('Connection failed: ${e.message}');
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: networkError,
              ),
            );
          }
          
          if (e.response != null) {
            final serverError = ServerException(
              'Server error: ${e.response?.statusMessage ?? "Unknown error"}',
              e.response?.statusCode,
            );
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                error: serverError,
              ),
            );
          }
          
          return handler.next(e);
        },
      ),
    );
  }

  /// Dynamically determines the base URL based on environment or platform.
  ///
  /// Can be configured at build/run time via:
  /// `--dart-define=API_BASE_URL=https://api.yourdomain.com`
  ///
  /// Falls back to local development URLs if unspecified (debug/profile only;
  /// release builds require an https URL — see [resolveBaseUrl]).
  String _getBaseUrl() {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    return resolveBaseUrl(
      definedUrl: definedUrl,
      isRelease: kReleaseMode,
      isAndroid: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
    );
  }

  /// Resolves the API base URL from the compile-time [definedUrl].
  ///
  /// In release builds ([isRelease]), [definedUrl] must be a valid `https://`
  /// URL; otherwise a [StateError] is thrown so a misconfigured build fails
  /// immediately at launch instead of silently calling a localhost address
  /// that doesn't exist on users' phones.
  ///
  /// In debug/profile builds an empty [definedUrl] falls back to the local
  /// development proxy (`10.0.2.2` on the Android emulator when [isAndroid]).
  @visibleForTesting
  static String resolveBaseUrl({
    required String definedUrl,
    required bool isRelease,
    required bool isAndroid,
  }) {
    if (isRelease) {
      if (definedUrl.isEmpty) {
        return 'https://agnambie-backend.onrender.com';
      }
      final uri = Uri.tryParse(definedUrl);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw StateError(
          'API_BASE_URL must be set to an https:// URL for release builds. '
          'Build with --dart-define=API_BASE_URL=https://api.yourdomain.com',
        );
      }
      return definedUrl;
    }

    if (definedUrl.isNotEmpty) {
      return definedUrl;
    }

    // 10.0.2.2 is the special alias to your host loopback interface from an Android emulator.
    if (isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    // For iOS Simulator, Web, or native desktop, localhost works fine.
    return 'http://localhost:8080';
  }
}
