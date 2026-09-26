// -----------------------------------------------------------------------------
// File: api_exception.dart
// Purpose: Declares the custom exception hierarchy used across network and API
//          operations to handle errors in a strongly typed manner.
// Author: Agnambie Team
// Creation Date: 2026-09-26
// Last Modified: 2026-09-26
// -----------------------------------------------------------------------------

// Base class for all API-related exceptions.
abstract class ApiException implements Exception {
  /// Human-readable description of the error.
  final String message;

  /// Creates an [ApiException] with the specified [message].
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Thrown when there is no network connection or a timeout occurs.
class NetworkException extends ApiException {
  /// Creates a [NetworkException] with the specified [message].
  const NetworkException(super.message);
}

/// Thrown when the server returns a non-200 status code.
class ServerException extends ApiException {
  /// The HTTP response status code, or `null` if unavailable.
  final int? statusCode;

  /// Creates a [ServerException] with an error [message] and an optional HTTP [statusCode].
  const ServerException(super.message, [this.statusCode]);

  @override
  String toString() {
    // Include the HTTP status code in the output string if present
    if (statusCode != null) {
      return 'ServerException ($statusCode): $message';
    }
    return 'ServerException: $message';
  }
}

/// Thrown when an expected audio resource is unavailable for a language.
class NoAudioAvailableException extends ApiException {
  /// Creates a [NoAudioAvailableException] with the specified [message].
  const NoAudioAvailableException(super.message);
}

/// Thrown when JSON parsing fails or expected payload fields are missing.
class DataParsingException extends ApiException {
  /// Creates a [DataParsingException] with the specified [message].
  const DataParsingException(super.message);
}

