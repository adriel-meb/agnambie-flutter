// -----------------------------------------------------------------------------
// File: api_logger.dart
// Purpose: Structured ANSI colored terminal logger for HTTP requests and telemetry.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ANSI terminal color codes for formatted debug console outputs.
class _Ansi {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String gray = '\x1B[90m';
}

/// Helper providing structured, color-coded logging for network and analytics events.
class ApiLogger {
  /// Formats and logs an outgoing HTTP request.
  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final method = options.method.toUpperCase();
    final methodColor = _getMethodColor(method);
    final path = options.uri.path;
    final query = options.uri.query.isNotEmpty ? '?${options.uri.query}' : '';

    debugPrint(
      '${_Ansi.cyan}🌐 [HTTP]${_Ansi.reset} '
      '$methodColor$method${_Ansi.reset} '
      '${_Ansi.bold}$path$query${_Ansi.reset}',
    );
  }

  /// Formats and logs a successful HTTP response with timing and status code.
  static void logResponse(Response<dynamic> response, Duration duration) {
    if (!kDebugMode) return;

    final statusCode = response.statusCode ?? 200;
    final statusColor = _getStatusColor(statusCode);
    final statusText = response.statusMessage ?? (statusCode == 200 ? 'OK' : '');
    final path = response.requestOptions.uri.path;
    final ms = duration.inMilliseconds;

    debugPrint(
      '${_Ansi.green}✅ [HTTP]${_Ansi.reset} '
      '$statusColor$statusCode $statusText${_Ansi.reset} '
      '${_Ansi.bold}$path${_Ansi.reset} '
      '${_Ansi.magenta}(${ms}ms)${_Ansi.reset}',
    );
  }

  /// Formats and logs a failed HTTP request with error details and timing.
  static void logError(DioException error, Duration? duration) {
    if (!kDebugMode) return;

    final statusCode = error.response?.statusCode;
    final path = error.requestOptions.uri.path;
    final durStr = duration != null ? ' ${_Ansi.magenta}(${duration.inMilliseconds}ms)${_Ansi.reset}' : '';
    final reason = error.message ?? error.error?.toString() ?? 'Network failure';

    debugPrint(
      '${_Ansi.red}❌ [HTTP]${_Ansi.reset} '
      '${_Ansi.red}${statusCode != null ? '$statusCode ERR' : 'FAILED'}${_Ansi.reset} '
      '${_Ansi.bold}$path${_Ansi.reset}$durStr '
      '${_Ansi.gray}— $reason${_Ansi.reset}',
    );
  }

  /// Formats and logs an analytics batch sync or telemetry event.
  static void logAnalytics(String message) {
    if (!kDebugMode) return;

    debugPrint(
      '${_Ansi.yellow}📊 [ANALYTICS]${_Ansi.reset} '
      '${_Ansi.green}$message${_Ansi.reset}',
    );
  }

  static String _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return _Ansi.blue;
      case 'POST':
        return _Ansi.green;
      case 'DELETE':
        return _Ansi.red;
      case 'PUT':
      case 'PATCH':
        return _Ansi.yellow;
      default:
        return _Ansi.reset;
    }
  }

  static String _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return _Ansi.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return _Ansi.cyan;
    } else if (statusCode >= 400 && statusCode < 500) {
      return _Ansi.yellow;
    } else {
      return _Ansi.red;
    }
  }
}
