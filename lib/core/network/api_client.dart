// -----------------------------------------------------------------------------
// File: api_client.dart
// Purpose: Configures and manages the singleton HTTP client (Dio) for network
//          requests, including base URL resolution, timeouts, and error handling.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'api_exception.dart';

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
          debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
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
          debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('<-- Error: ${e.message} on ${e.requestOptions.uri}');
          
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
  /// Falls back to local development URLs if unspecified.
  String _getBaseUrl() {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) {
      return definedUrl;
    }

    // 10.0.2.2 is the special alias to your host loopback interface from an Android emulator.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    // For iOS Simulator, Web, or native desktop, localhost works fine.
    return 'http://localhost:8080';
  }
}
